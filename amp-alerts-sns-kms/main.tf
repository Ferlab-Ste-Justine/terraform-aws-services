resource "aws_kms_key" "amp_alerts" {
  description             = var.amp_instance_identifier != null ? "Encryption for ${var.amp_instance_identifier} AMP alerting SNS topic" : "Encryption for AMP alerting SNS topic"
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "amp_alerts" {
  name          = var.amp_instance_identifier != null ? "alias/${var.amp_instance_identifier}-amp-alerts" : "alias/amp-alerts"
  target_key_id = aws_kms_key.amp_alerts.key_id
}

resource "aws_kms_key_policy" "amp_alerts" {
  key_id = aws_kms_key.amp_alerts.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowAccountAdmin"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${var.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowAMPToUseKey"
        Effect    = "Allow"
        Principal = { Service = "aps.amazonaws.com" }
        Action    = ["kms:GenerateDataKey", "kms:Decrypt"]
        Resource  = "*"
        Condition = {
          StringEquals = { "aws:SourceAccount" = var.account_id }
        }
      },
      {
        Sid       = "AllowSNSToUseKey"
        Effect    = "Allow"
        Principal = { Service = "sns.amazonaws.com" }
        Action    = ["kms:GenerateDataKey", "kms:Decrypt"]
        Resource  = "*"
        Condition = {
          StringEquals = { "aws:SourceAccount" = var.account_id }
        }
      }
    ]
  })
}