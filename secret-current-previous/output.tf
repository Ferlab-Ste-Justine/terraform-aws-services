output "current_value" {
  description = "Current secret value"
  value       = data.aws_secretsmanager_secret_version.current.secret_string
}

output "previous_value" {
  description = "Previous secret value. May be null if secret is still at first version"
  value       = local.previous_exists ? data.aws_secretsmanager_secret_version.previous.0.secret_string : null
}