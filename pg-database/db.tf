locals {
  owner_name = var.db_owner.name != "" ? var.db_owner.name : var.db_name
}

data "aws_secretsmanager_secret" "owner_role" {
  count = var.db_owner.secret_name != "" ? 1 : 0
  name  = var.db_owner.secret_name
}

data "aws_secretsmanager_secret_version" "owner_role" {
  count     = var.db_owner.secret_name != "" ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.owner_role.0.id
}

resource "postgresql_role" "owner" {
  count    = var.db_owner.secret_name != "" ? 1 : 0
  name     = local.owner_name
  login    = true
  password = data.aws_secretsmanager_secret_version.owner_role.0.secret_string
}

resource "postgresql_database" "database" {
  name              = var.db_name
  owner             = local.owner_name
  connection_limit  = var.connection_limit
  allow_connections = true
}