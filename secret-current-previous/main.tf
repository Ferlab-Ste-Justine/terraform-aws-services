data "aws_secretsmanager_secret" "staged_secret" {
  name = var.secret_name
}

data "aws_secretsmanager_secret_versions" "staged_secret" {
  secret_id = data.aws_secretsmanager_secret.staged_secret.id
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.staged_secret.id
}

locals {
  previous_exists = length([
    for secret_version in data.aws_secretsmanager_secret_versions.staged_secret.versions: 1 if contains(secret_version.version_stages, "AWSPREVIOUS")
  ]) > 0
}

data "aws_secretsmanager_secret_version" "previous" {
  count         = local.previous_exists ? 1 : 0
  secret_id     = data.aws_secretsmanager_secret.staged_secret.id
  version_stage = "AWSPREVIOUS"
}