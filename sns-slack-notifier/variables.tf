variable "name" {
  description = "Base name for all resources (Lambda, IAM role, log group)"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic the Lambda subscribes to"
  type        = string
}

variable "slack_webhook_secret" {
  description = "Secrets Manager secret name holding the Slack webhook URL"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
