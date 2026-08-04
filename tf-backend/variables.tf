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

variable "lifecycle" {
  description = "Lifecycle configuration for the state bucket."
  type = object({
    noncurrent_version_glacier_days = optional(number, 90)
  })
  default = {}
}
