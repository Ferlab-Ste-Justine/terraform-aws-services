output "users_parameter_arn" {
  description = "ARN of the parameter holding the users list."
  value       = aws_ssm_parameter.users.arn
}

output "gpg_keys_prefix" {
  description = "SSM path prefix under which the gpg keys are stored, null when no key is uploaded."
  value       = local.gpg_keys_prefix
}

output "gpg_key_arns" {
  description = "ARNs of the gpg key parameters, by username."
  value       = { for username, parameter in aws_ssm_parameter.gpg_key : username => parameter.arn }
}
