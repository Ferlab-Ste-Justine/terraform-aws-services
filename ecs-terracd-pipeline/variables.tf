variable "account_id" {
  description = "Id of the aws account the pipeline is attached to"
  type        = string
}

variable "region" {
  description = "AWS region of the pipeline"
  type        = string
}

variable "name" {
  description = "Name of the pipeline"
  type        = string
}

variable "vpc_id" {
  description = "Id of the aws vpc the pipeline is attached to. Is an optional argument unless no security group is passed to the scheduler"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags for pipeline resources"
  type        = map(string)
  default     = {}
}

variable "task" {
  description = "Parameters related to the task"
  type        = object({
    container_image          = optional(string, "ferlabcrsj/terracd-aws:v0.2.0")
    cpu                      = optional(number, 512)
    memory                   = optional(number, 1024)
    execution_role_arn       = string
    task_role_arn            = string
    environment_variables    = map(string)
    terracd_config           = string
    git_auth                 = optional(object({
      http = optional(object({
        username            = optional(string, "git")
        password_secret_arn = string
      }))
    }))
    git_trusted_signing_keys = optional(list(string), [])
    metrics_enabled          = optional(bool, false)
  })
}

variable "scheduler" {
  description = "Parameters related to the scheduler"
  type        = object({
    schedule_expression = optional(string, "rate(15 minutes)")
    max_retry_attempts  = optional(number, 0)
    esc_cluster_arn     = string
    subnets             = list(string)
    security_groups     = list(string)
  })
}
