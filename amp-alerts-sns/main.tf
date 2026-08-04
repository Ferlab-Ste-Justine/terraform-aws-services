data "aws_prometheus_workspace" "amp" {
  workspace_id = var.workspace_id
}

resource "aws_sns_topic" "amp_alerts" {
  name              = var.amp_instance_identifier != null ? "${var.amp_instance_identifier}-amp-alerts" : "amp-alerts"
  kms_master_key_id = var.sns_kms_key_arn
}

resource "aws_sns_topic_policy" "amp_alerts" {
  arn = aws_sns_topic.amp_alerts.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowAMPPublish"
        Effect    = "Allow"
        Principal = { Service = "aps.amazonaws.com" }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.amp_alerts.arn
        Condition = {
          ArnEquals = { "aws:SourceArn" = data.aws_prometheus_workspace.amp.arn }
        }
      }
    ]
  })
}

resource "aws_prometheus_alert_manager_definition" "qlin" {
  workspace_id = var.workspace_id
  definition   = templatefile(
    "${path.module}/templates/mimir_config.yml.tpl", 
    {
      alertmanager_config = templatefile(
        "${path.module}/templates/alertmanager_config.yml.tpl",
        {
          region = var.region
          sns_topic_arn = aws_sns_topic.amp_alerts.arn
        }
      )
    }
  )
}