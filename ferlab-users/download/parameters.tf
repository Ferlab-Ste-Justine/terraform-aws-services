data "aws_ssm_parameter" "users" {
  name = var.storage.users_parameter
}

data "aws_ssm_parameters_by_path" "gpg_keys" {
  for_each = var.storage.gpg_keys_prefix != null ? { keys = var.storage.gpg_keys_prefix } : {}

  path      = "/${trim(each.value, "/")}"
  recursive = false
}
