data "aws_secretsmanager_secret" "slack_webhook" {
  name = var.slack_webhook_secret
}

resource "aws_iam_role" "notifier" {
  name = var.name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "notifier" {
  name = var.name
  role = aws_iam_role.notifier.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [data.aws_secretsmanager_secret.slack_webhook.arn]
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/lambda/${var.name}:*"
      },
    ]
  })
}

data "archive_file" "notifier" {
  type        = "zip"
  source_file = "${path.module}/files/notifier.py"
  output_path = "${path.module}/files/notifier.zip"
}

resource "aws_lambda_function" "notifier" {
  function_name    = var.name
  role             = aws_iam_role.notifier.arn
  filename         = data.archive_file.notifier.output_path
  source_code_hash = data.archive_file.notifier.output_base64sha256
  handler          = "notifier.handler"
  runtime          = "python3.12"
  timeout          = 30

  environment {
    variables = {
      SLACK_WEBHOOK_SECRET = var.slack_webhook_secret
    }
  }

  tags = var.tags
}

resource "aws_lambda_permission" "notifier" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notifier.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arn
}

resource "aws_sns_topic_subscription" "notifier" {
  topic_arn = var.sns_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.notifier.arn
}
