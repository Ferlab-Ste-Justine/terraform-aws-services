data "aws_iam_policy_document" "kms_key_policy" {
  version = "2012-10-17"

  statement {
    sid = "AllowAccessViaIAMPermissions"

    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }

    actions = [
      "kms:*"
    ]

    resources = ["*"]
  }

  statement {
    sid = "AllowAccessViaSecretsManager"

    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["secretsmanager.${var.region}.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [var.account_id]
    }

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]

    resources = ["*"]
  }
}

resource "aws_kms_key" "rds" {
  description             = "Encryption key for persisted RDS instance ${var.rds_instance_identifier} data"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 10
  policy                  = data.aws_iam_policy_document.kms_key_policy.json

  enable_key_rotation = true

  tags = {
    "Name" = "RDS database encryption for ${var.rds_instance_identifier}"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.rds_instance_identifier}-encryption-key"
  target_key_id = aws_kms_key.rds.key_id
}
