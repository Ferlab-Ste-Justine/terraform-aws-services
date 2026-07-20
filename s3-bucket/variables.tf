variable "name" {
  description = "Bucket name (must be globally unique)"
  type        = string
}

variable "force_destroy" {
  description = "If true, the bucket can be destroyed even when it contains objects. Set true for QA/throwaway envs only."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Extra tags merged on top of the provider's default_tags. Do not duplicate default_tags  here."
  type        = map(string)
  default     = {}
}

variable "cors_rules" {
  description = "CORS rules for the bucket. Empty (default) creates no CORS configuration."
  type = list(object({
    allowed_headers = optional(list(string), [])
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string), [])
    max_age_seconds = optional(number, 3000)
  }))
  default = []
}
