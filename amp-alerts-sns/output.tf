output "sns_topic_arn" {
  description = "Arn of sns topic where alerts are sent"
  value       = aws_sns_topic.amp_alerts.arn
}