variable "terracd_jobs" {
  description = "List of terracd jobs"
  type = list(object({
    tag                      = string
    run_interval_threshold  = number
    apply_interval_threshold = number
    failure_time_frame       = number
    provider_use_time_frame  = number
    unit                     = string
    alert_labels             = map(string)
    legacy_names             = optional(bool, false)
  }))
  default = []

  validation {
    condition     = alltrue([for job in var.terracd_jobs: contains(["minute", "hour"], job.unit)])
    error_message = "Units for terracd_jobs must be 'minute' or 'hour'"
  }
}

variable "node_exporter_jobs" {
  description = "List of node exporter jobs"
  type = list(object({
    tag                        = string
    memory_usage_threshold     = number
    cpu_usage_threshold        = number
    expected_disks_count       = number
    disk_space_usage_threshold = number
    disk_io_usage_threshold    = number
    disk_count_selector        = optional(object({
      include_path_regex = optional(string)
      exclude_path_regex = optional(string)
    }), {})
    alert_labels               = map(string)
  }))
  default = []
}

variable "blackbox_exporter_jobs" {
  description = "List of blackbox exporter jobs"
  type = list(object({
    tag                      = string
    unavailability_tolerance = string
    max_acceptable_latency   = number
    cert_renewal_window      = number
    has_tls                  = bool
    expect_recent_tls        = bool
    alert_labels             = map(string)
  }))
  default = []
}

variable "kubernetes_exporter_jobs" {
  description = "List of kubernetes exporter jobs"
  type = list(object({
    tag                    = string
    volume_usage_threshold = optional(number, 85)
    expected_services      = list(object({
      namespace            = string
      name                 = string
      expected_min_count   = number
      expected_start_delay = number
      alert_labels         = map(string)
    }))
  }))
  default = []
}

variable "starrocks_exporter_jobs" {
  description = "List of starrocks exporter jobs"
  type = list(object({
    tag                       = string
    fe = object({
      count                       = number
      heap_usage_threshold        = optional(number)
      query_error_rate_threshold  = number
      compaction_score_threshold  = optional(number, 100)
      meta_log_count_threshold    = optional(number, 100000)
      p95_query_latency_threshold = optional(number)
      txn_publish_delay_threshold = optional(number)
    })
    be = object({
      count                      = number
      cpu_usage_threshold        = optional(number)
      cpus_per_node              = optional(number)
      memory_usage_threshold     = optional(number)
      memory_per_node            = optional(number)
      disk_space_usage_threshold = optional(number)
      disk_io_usage_threshold    = optional(number)
    })
    alert_labels              = map(string)
  }))
  default = []
}


variable "heartbeat" {
  description = "Parameters for a heartbeat alert that triggers approximately around a given utc time each day and confirms alerting is still operational"
  type = object({
    enabled      = optional(bool, true)
    hour         = number
    minute       = number
    alert_labels = map(string)
  })
  default = {
    enabled      = false
    hour         = 0
    minute       = 0
    alert_labels = {}
  }
}

variable "workspace_id" {
  description = "Id of the prometheus workspace to attach the configuration to"
  type = string
}