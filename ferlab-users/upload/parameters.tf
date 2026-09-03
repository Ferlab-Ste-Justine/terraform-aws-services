locals {
  gpg_keys_prefix = var.storage.gpg_keys_prefix != null ? "/${trim(var.storage.gpg_keys_prefix, "/")}/" : null
}

resource "aws_ssm_parameter" "users" {
  name  = var.storage.users_parameter
  type  = "String"
  tier  = var.storage.tier
  value = local.users_document
  tags  = var.tags

  lifecycle {
    precondition {
      condition     = local.valid
      error_message = "The users list failed validation. See the check blocks in this module for the failing condition."
    }
  }
}

resource "aws_ssm_parameter" "gpg_key" {
  for_each = var.gpg_keys

  name  = "${local.gpg_keys_prefix}${each.key}"
  type  = "String"
  tier  = var.storage.tier
  value = chomp(each.value)
  tags  = var.tags

  lifecycle {
    precondition {
      condition     = local.valid
      error_message = "The gpg keys failed validation. See the check blocks in this module for the failing condition."
    }
  }
}
