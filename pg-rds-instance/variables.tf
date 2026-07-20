variable "region" {
  description = "Initial AWS deployment region"
  type        = string
  default     = "ca-central-1"

}

variable "account_id" {
  description = "Account ID"
  type        = string

}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = ""
}

variable "rds_instance_identifier" {
  description = "The name of the RDS instance"
  type        = string
}

variable "snapshots" {
  type = object({
    skip_on_deletion = optional(bool, false)
    daily_window = optional(string, "00:00-02:00")
    retention_period = optional(number, 7)
  })
  default = {
    skip_on_deletion = false
    daily_window  = "00:00-02:00"
    retention_period = 7
  }
}

variable "postgres_version" {
  description = "Version of postgres to use"
  type        = string
  default     = "14"
}

//See: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.Types.html
variable "rds_instance_class" {
  description = "Instance class for the RDS instace"
  type        = string
  default     = "db.m6i.xlarge"
}


variable "performance_insights" {
  description = "Rds performance insights parameters. "
  type = object({
    enabled          = optional(bool, true)
    retention_period = optional(number, 7)
    kms_key_id       = optional(string, "")
  })
  default = {
    enabled = false
    retention_period = 0
    kms_key_id = ""
  }
}

//See: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html
variable "storage" {
  description = "Rds storage parameters."
  type = object({
    type               = optional(string, "gp2")
    allocated          = optional(number, 20)
    max_allocated      = optional(number, 0)
    kms_key_arn        = optional(string, "")
  })
  default = {
    type               = "gp2"
    allocated          = 20
    max_allocated      = 0
    kms_key_arn        = ""
  }
}

variable "zones" {
  type = object({
    multi_az = optional(bool, true)
    availability_zone = optional(string, "")
  })
  default = {
    multi_az = true
    availability_zone = ""
  }
}

variable "admin_credentials" {
  description = "Parameters related to management of root credentials"
  type = object({
    username = optional(string, "root")
    password = string
  })
  sensitive = true
}

variable "maintenance" {
  description = "Parameters related to maintenance"
  type = object({
    window = optional(string, "sat:02:00-sat:04:00")
    upgrade_minor_version = optional(bool, true)
  })
  default = {
    window = "sat:02:00-sat:04:00"
    upgrade_minor_version = true
  }
}

variable "enhanced_monitoring" {
  description = "Parameters related to enhanced monitoring"
  type = object({
    interval = optional(number, 60)
    role_arn = string
  })
  default = {
    interval = 0
    role_arn = ""
  }
}

variable "networking" {
  description = "Parameters related to networking"
  type = object({
    subnet_ids = list(string)
    access_control = optional(object({
      existing_sg_ids = optional(list(string), [])
      allowed_sg_ids = optional(list(string), [])
    }), {
      existing_sg_ids = []
      allowed_sg_ids = []
    })
    #Note that for a true value to work, the database still need to belong to a public subnet 
    #and have security groups that allow the incoming traffic.
    publicly_accessible = optional(bool, false)
  })
}
