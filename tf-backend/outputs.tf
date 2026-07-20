output "bucket_name" {
  description = "S3 bucket name for the Terraform remote state."
  value       = aws_s3_bucket.backend.id
}

output "dynamodb_table_name" {
  description = "DynamoDB table name for state locking."
  value       = aws_dynamodb_table.backend.name
}
