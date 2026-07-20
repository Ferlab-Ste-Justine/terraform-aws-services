variable "region" {
  description = "Initial AWS deployment region"
  type        = string
  default     = "ca-central-1"

}

variable "account_id" {
  description = "Account ID"
  type        = string

}

variable "rds_instance_identifier" {
  description = "The name of the RDS instance"
  type        = string
}