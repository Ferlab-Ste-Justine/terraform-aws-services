resource "aws_cloudwatch_log_group" "pipeline_logs" {
  name              = "/terracd-pipeline/${var.name}"
  retention_in_days = 30
  tags              = var.tags
}

resource "aws_ssm_parameter" "terracd_entrypoint" {
  name = "/terracd-pipeline/${var.name}/terracd-entrypoint"
  type = "String"
  value = templatefile("${path.module}/entrypoint.sh.tpl", {
    terracd_config = var.task.terracd_config
    git_auth       = var.task.git_auth
  })

  tags = var.tags
}

resource "aws_iam_policy" "pipeline_entrypoint_access" {
  name = "terracd-pipeline-entrypoint-access-${var.name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:ListTagsForResource"]
        Resource = [aws_ssm_parameter.terracd_entrypoint.arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "pipeline_entrypoint_access" {
  role       = element(split("/", var.task.task_role_arn), length(split("/", var.task.task_role_arn)) - 1)
  policy_arn = aws_iam_policy.pipeline_entrypoint_access.arn
}

locals {
  amd_host = "aps-workspaces.${var.region}.amazonaws.com"

  environment_variables = concat(
    [for key, val in var.task.environment_variables : {
      name  = key
      value = val
    }], [{
      name = "TERRACD_CONFIG_FILE"
      value = "/etc/terracd/config.yml"
    }, {
      name = "SSM_ENTRYPOINT_PATH"
      value = "/terracd-pipeline/${var.name}/terracd-entrypoint"
    }], try(var.task.git_auth.http, null) != null ? [{
      name = "GIT_HTTP_USERNAME"
      value = var.task.git_auth.http.username
    }] : [],
    [for idx, key in var.task.git_trusted_signing_keys : {
      name = "GIT_TRUSTED_KEY_${idx + 1}"
      value = key
    }]
  )

  secrets = try(var.task.git_auth.http, null) != null ? [{
    name      = "GIT_HTTP_PASSWORD"
    valueFrom = var.task.git_auth.http.password_secret_arn
  }] : []
  
  containers = [{
    name       = "terracd"
    image      = var.task.container_images.terracd
    essential  = true
    entryPoint = ["entrypoint-ssm.sh"]
    environment = local.environment_variables

    secrets = local.secrets

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.pipeline_logs.name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }]
  containers_with_metrics = concat(local.containers, var.task.metrics_enabled ?  [{
    name       = "aws-sigv4-proxy"
    image      = var.task.container_images.sigv4_proxy
    essential  = true
    command = [
      "--port", ":8080",
      "--name", "aps",
      "--region", var.region,
      "--host", local.amd_host,
      "--sign-host", local.amd_host,
      "--upstream-url-scheme", "https",
      "--log-failed-requests",
    ]
    environment = [{name = "AWS_SDK_LOAD_CONFIG", value = "true"}]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.pipeline_logs.name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }] : [])
}

resource "aws_iam_role" "pipeline_task_role" {
  name = "terracd-pipeline-task-${var.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_ecs_task_definition" "pipeline_task" {
  family                   = "terracd-pipeline-${var.name}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task.cpu
  memory                   = var.task.memory
  task_role_arn            = var.task.task_role_arn
  execution_role_arn       = var.task.execution_role_arn

  container_definitions = jsonencode(local.containers_with_metrics)

  tags = var.tags
}

resource "aws_sqs_queue" "pipeline_scheduler_dlq" {
  name                      = "terracd-pipeline-scheduler-dlq-${var.name}"
  message_retention_seconds = 1209600 # 14 days (max)
  sqs_managed_sse_enabled   = true

  tags = var.tags
}

resource "aws_iam_role" "pipeline_scheduler" {
  name = "terracd-pipeline-scheduler-${var.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "scheduler.amazonaws.com" }
      Action    = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = var.account_id
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_policy" "pipeline_scheduler" {
  name = "terracd-pipeline-scheduler-${var.name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ecs:RunTask"
        Resource = aws_ecs_task_definition.pipeline_task.arn
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          var.task.task_role_arn,
          var.task.execution_role_arn,
        ]
      },
      {
        Effect   = "Allow"
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.pipeline_scheduler_dlq.arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "pipeline_scheduler" {
  role       = aws_iam_role.pipeline_scheduler.name
  policy_arn = aws_iam_policy.pipeline_scheduler.arn
}

resource "aws_scheduler_schedule" "pipeline_scheduler" {
  name = "terracd-pipeline-${var.name}"

  schedule_expression          = var.scheduler.schedule_expression
  schedule_expression_timezone = "UTC"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = var.scheduler.esc_cluster_arn
    role_arn = aws_iam_role.pipeline_scheduler.arn

    dead_letter_config {
      arn = aws_sqs_queue.pipeline_scheduler_dlq.arn
    }

    ecs_parameters {
      task_definition_arn = aws_ecs_task_definition.pipeline_task.arn
      launch_type         = "FARGATE"

      network_configuration {
        assign_public_ip = false
        subnets          = var.scheduler.subnets
        security_groups  = length(var.scheduler.security_groups) > 0 ? var.scheduler.security_groups : [aws_security_group.pipeline_task.0.id]
      }
    }

    retry_policy {
      maximum_retry_attempts = var.scheduler.max_retry_attempts
    }
  }
}