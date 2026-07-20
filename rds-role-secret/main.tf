resource "random_password" "role_password" {
  length           = var.password_length
  special          = true
  override_special = "!%*()-_=+[]:?"
}

resource "aws_secretsmanager_secret" "role_password" {
  name        = var.secret.name
  description = var.secret.description
}

resource "aws_secretsmanager_secret_version" "role_password" {
  secret_id     = aws_secretsmanager_secret.role_password.id
  secret_string = random_password.role_password.result
}
