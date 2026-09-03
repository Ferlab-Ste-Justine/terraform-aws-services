variable "storage" {
  description = "Where in SSM the users list and the gpg keys are stored."
  type = object({
    users_parameter = string
    gpg_keys_prefix = optional(string)
  })
}

variable "execution_time" {
  description = "Timestamp in ISO 8601 format used to prune expired grants. Defaults to the current time."
  type        = string
  default     = ""
}

variable "compute" {
  description = "Which processed maps to compute. The others are returned as null."
  type = object({
    users_by_username             = optional(bool, true)
    users_by_role                 = optional(bool, false)
    usernames_by_role             = optional(bool, true)
    users_by_environment          = optional(bool, false)
    usernames_by_environment      = optional(bool, true)
    users_by_environment_role     = optional(bool, false)
    usernames_by_environment_role = optional(bool, true)
  })
  default = {}
}
