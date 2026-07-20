# Output the ARN of the KMS key
output "kms_key_arn" {
  description = "The ARN of the KMS key used for encryption"
  value       = aws_kms_key.rds.arn
  sensitive   = true
}