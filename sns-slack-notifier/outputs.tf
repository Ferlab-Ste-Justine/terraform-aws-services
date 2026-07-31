output "lambda_arn" {
  description = "ARN of the Lambda notifier function"
  value       = aws_lambda_function.notifier.arn
}

output "lambda_name" {
  description = "Name of the Lambda notifier function"
  value       = aws_lambda_function.notifier.function_name
}
