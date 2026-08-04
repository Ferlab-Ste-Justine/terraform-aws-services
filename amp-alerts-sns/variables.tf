variable "amp_instance_identifier" {
  description = "Identifier for the amp instance"
  type        = string
  default     = null
}

variable "sns_kms_key_arn" {
  description = "Arn of the kms master used to encrypt sns messages"
  type        = string
}

variable "workspace_id" {
  description = "id of the prometheus workspace to attach alerts to"
  type = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ca-central-1"
}