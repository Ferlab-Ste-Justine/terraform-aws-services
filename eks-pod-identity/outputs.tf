output "role_arn" {
  description = "ARN of the IAM role assumed by pods using this service account"
  value       = aws_iam_role.pod_identity.arn
}

output "role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.pod_identity.name
}

output "namespace" {
  description = "Kubernetes namespace"
  value       = var.namespace
}

output "service_account" {
  description = "Kubernetes service account name"
  value       = var.service_account
}
