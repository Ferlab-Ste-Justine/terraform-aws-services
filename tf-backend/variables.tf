variable "pipeline_name" {
  description = "Short pipeline name used to derive resource names (e.g. 'rds', 'starrocks')."
  type        = string
}

variable "account_id" {
  description = "AWS account ID — appended to the bucket name for global uniqueness."
  type        = string
}

variable "region" {
  description = "AWS region — appended to the bucket name for global uniqueness."
  type        = string
}

variable "noncurrent_version_glacier_days" {
  description = "Transition noncurrent versions to GLACIER_IR after this many days. Set to 0 to disable."
  type        = number
  default     = 90
}
