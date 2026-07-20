output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.service.endpoint
}

output "rds_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.service.arn
}
