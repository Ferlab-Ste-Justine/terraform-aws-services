variable "file_system_name" {
  description = "Logical name used in tags (Name) and as a prefix for the security group name. The file system's own AWS-side identifier (fs-XXXX) is auto-generated."
  type        = string
}

variable "subnet_id" {
  description = "Single private subnet (single-AZ) where the file system is provisioned. FSx Lustre is mono-AZ; pods that mount it must be scheduled in the same AZ."
  type        = string
}

variable "security_group_ids" {
  description = "Security groups attached to the file system's ENIs. Created by the parent stack (terraform/lustre/security_groups.tf) and passed in so this submodule stays decoupled from the SG lifecycle."
  type        = list(string)
}

variable "storage_capacity" {
  description = "Storage capacity in GiB. Must be a multiple of 1200 (i.e. 1.2 TiB increments). On PERSISTENT_2 SSD, throughput scales with capacity (baseline = capacity x per_unit_storage_throughput / 1024)."
  type        = number
  default     = 4800

  validation {
    condition     = var.storage_capacity >= 1200 && var.storage_capacity % 1200 == 0
    error_message = "storage_capacity must be at least 1200 and a multiple of 1200 (PERSISTENT_2 SSD minimum is 1.2 TiB)."
  }
}

variable "per_unit_storage_throughput" {
  description = "Throughput per TiB of storage in MB/s. Valid PERSISTENT_2 SSD values are 125, 250, 500, 1000. Higher tiers cost more per GB-month but multiply the baseline throughput available for the same storage."
  type        = number
  default     = 500

  validation {
    condition     = contains([125, 250, 500, 1000], var.per_unit_storage_throughput)
    error_message = "per_unit_storage_throughput must be 125, 250, 500, or 1000 (PERSISTENT_2 SSD)."
  }
}

variable "data_compression_type" {
  description = "On-disk compression: LZ4 (free, gain on text/gVCF) or NONE."
  type        = string
  default     = "LZ4"

  validation {
    condition     = contains(["LZ4", "NONE"], var.data_compression_type)
    error_message = "data_compression_type must be LZ4 or NONE."
  }
}

variable "data_repository_associations" {
  description = "Map of DRAs to create on the file system. Key is a short logical name (e.g. \"reference\"). Each value specifies the filesystem path, the S3 path, whether to bulk-import metadata at creation, and which event lists to enable for auto-import / auto-export. Empty event lists disable that direction."
  type = map(object({
    file_system_path       = string
    data_repository_path   = string
    batch_import_on_create = bool
    auto_import_events     = list(string)
    auto_export_events     = list(string)
  }))
  default = {}
}

variable "tags" {
  description = "Extra tags merged on top of the provider's default_tags. Do not duplicate default_tags here."
  type        = map(string)
  default     = {}
}
