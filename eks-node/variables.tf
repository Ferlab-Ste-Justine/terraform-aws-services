variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_security_group_id" {
  description = "Security group ID created by the EKS cluster (used in NodeClass securityGroupSelectorTerms)"
  type        = string
}

variable "external_node_security_group_id" {
  description = "Optional SG ID attached to nodes via the NodeClass securityGroupSelectorTerms, in addition to the EKS-managed cluster SG. Used to carry cross-stack rules (e.g. nodes to FSx Lustre) on a long-lived SG owned by terraform/kubernetes/."
  type        = string
  default     = null
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs the NodeClass selects from"
  type        = list(string)
}

variable "eks_node_role_name" {
  description = "Name of the IAM role assumed by EKS Auto Mode nodes (created by the eks module)"
  type        = string
}

variable "nodepool_name" {
  description = "Name of the Karpenter NodePool"
  type        = string
}

variable "nodeclass_name" {
  description = "Name of the EKS Auto Mode NodeClass"
  type        = string
}

variable "capacity_type" {
  description = "Capacity types allowed by the NodePool, e.g. [\"on-demand\"] or [\"spot\", \"on-demand\"]"
  type        = list(string)
}

variable "instance_categories" {
  description = "EC2 instance categories allowed by the NodePool, e.g. [\"c\", \"r\", \"m\"]"
  type        = list(string)
}

variable "architecture" {
  description = "CPU architectures allowed by the NodePool, e.g. [\"amd64\"] or [\"arm64\"]"
  type        = list(string)
}

variable "ephemeral_storage" {
  description = "Ephemeral storage config for nodes provisioned by this NodeClass. `size` is a Kubernetes quantity (e.g. \"80Gi\")."
  type = object({
    iops       = number
    size       = string
    throughput = number
  })
  default = {
    iops       = 3000
    size       = "80Gi"
    throughput = 125
  }
}

variable "labels" {
  description = "Kubernetes labels applied to nodes provisioned by this NodePool (workloads target via nodeSelector)"
  type        = map(string)
  default     = {}
}

variable "topology_zones" {
  description = "Optional list of AZs (e.g. [\"ca-central-1a\"]) to pin this NodePool to via a Karpenter requirement on topology.kubernetes.io/zone. Empty list (default) leaves Karpenter free to schedule across every subnet in the NodeClass. Use to co-locate pods with a single-AZ resource (FSx Lustre, EBS volume, etc.)."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags propagated by Karpenter onto every EC2 instance it launches via this NodeClass. MUST include the SQSS_* compliance tags - the org SCP explicitly denies ec2:RunInstances when those tags are missing on the request. Provider default_tags don't propagate here because this is a Kubernetes CRD, not a terraform-managed AWS resource."
  type        = map(string)
  default     = {}
}

variable "consolidate_after" {
  description = "Karpenter spec.disruption.consolidateAfter: how long a node must stay empty or underutilized before Karpenter consolidates (drains) it. The Karpenter v1 default of \"0s\" consolidates immediately, which thrashes bursty workloads and evicts running pods. A non-zero value lets transient dips settle before disruption."
  type        = string
  default     = "5m"
}
