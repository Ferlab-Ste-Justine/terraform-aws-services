variable "storage" {
  description = "Where in SSM the users list and the gpg keys are stored."
  type = object({
    users_parameter = string
    gpg_keys_prefix = optional(string)
    tier            = optional(string, "Standard")
  })

  validation {
    condition     = contains(["Standard", "Advanced"], var.storage.tier)
    error_message = "storage.tier must be Standard or Advanced."
  }
}

variable "roles" {
  description = "List of valid roles."
  type        = list(string)
}

variable "environments" {
  description = "List of valid environments. Empty for a single-environment project."
  type        = list(string)
  default     = []
}

variable "required_attributes" {
  description = "Required user attribute keys, by role."
  type        = map(list(string))
  default     = {}
}

variable "users" {
  description = "List of users."
  type = list(object({
    username     = string
    roles        = list(string)
    environments = optional(list(string), [])
    attributes   = optional(map(string), {})
    temporary_grants = optional(list(object({
      name       = string
      scope      = string
      expires_at = string
    })), [])
  }))

  validation {
    condition = alltrue([
      for user in var.users : user.username != ""
    ])
    error_message = "Each user's username should not be empty."
  }

  validation {
    condition = alltrue([
      for user in var.users : alltrue([
        for grant in user.temporary_grants : grant.name != "" && grant.scope != ""
      ])
    ])
    error_message = "Each entry in each user's temporary_grants must have non-empty name and scope fields."
  }

  validation {
    condition = alltrue(flatten([
      for user in var.users : [
        for grant in user.temporary_grants : can(formatdate("", grant.expires_at))
      ]
    ]))
    error_message = "Each entry in each user's temporary_grants must have a valid timestamp for its expires_at field."
  }

  validation {
    condition     = length(distinct(var.users[*].username)) == length(var.users)
    error_message = "Usernames must be unique."
  }
}

variable "gpg_keys" {
  description = "Armored public keys of trusted git authors, by username."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags for the created parameters."
  type        = map(string)
  default     = {}
}
