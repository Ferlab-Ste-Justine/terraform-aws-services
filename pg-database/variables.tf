variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "connection_limit" {
  description = "Name of the database"
  type        = number
  default     = -1
}

variable "db_owner" {
  description = "Properties of the database owner role"
  type = object({
    name        = optional(string, "")
    secret_name = optional(string, "")
  })
  default = {
    name = ""
    secret_name = ""
  }
}