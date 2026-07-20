variable "region" {
  description = "AWS region for the EKS cluster"
  type        = string
  default     = "ca-central-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "k8s_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.35"
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs the cluster will run in"
  type        = list(string)
  default     = []
}

variable "cluster_additional_security_group_ids" {
  description = "Extra security group IDs attached to the EKS control-plane ENIs via vpc_config.security_group_ids. Used to carry cross-stack rules (e.g. bastion to API) on a long-lived SG defined alongside the cluster in terraform/kubernetes/security_groups.tf, so targeted destroy of the cluster resource does not break those rules."
  type        = list(string)
  default     = []
}

variable "builtin_node_pools" {
  description = "Built-in EKS Auto Mode node pools to enable. Defaults to empty: the AWS-managed NodeClass behind these pools does not propagate caller tags onto launched EC2 instances, so they fail SCPs that require tags. Run all compute on a custom NodePool/NodeClass instead."
  type        = list(string)
  default     = []
}

variable "zonal_shift_enabled" {
  description = "Enable EKS zonal shift on the cluster (lets traffic be moved away from an impaired AZ)"
  type        = bool
  default     = true
}

variable "eks_admin_role_arn" {
  description = "ARN of the IAM role granted cluster-admin via EKS access entry"
  type        = string
}

variable "eks_cluster_role_name" {
  description = "Name of the IAM role created for the EKS control plane"
  type        = string
}

variable "eks_node_role_name" {
  description = "Name of the IAM role created for EKS Auto Mode nodes"
  type        = string
}

variable "tags" {
  description = "Extra tags merged on top of the provider's default_tags. Do not duplicate default_tags here."
  type        = map(string)
  default     = {}
}

variable "enabled_cluster_log_types" {
  description = "EKS control-plane log types shipped to CloudWatch Logs. Default [\"audit\"] is the minimum required for traceability of the Confidentiel data classification. Valid values: api, audit, authenticator, controllerManager, scheduler."
  type        = list(string)
  default     = ["audit"]
}
