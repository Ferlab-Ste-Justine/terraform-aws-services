variable "secret" {
  description = "Name and description of the secret in secret manager."
  type = object({
    name         = string
    description = string
  })
}

variable "password_length" {
  description = "Length of the generated passwords."
  type        = number
  default     = 32
}