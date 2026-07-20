variable "cluster_name" {
  description = "Name of the EKS cluster the Pod Identity association binds to"
  type        = string
}

variable "account_id" {
  description = "AWS account ID (used in the IAM role trust policy condition)"
  type        = string
}

variable "region" {
  description = "AWS region of the cluster (used in the IAM role trust policy condition)"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace of the service account"
  type        = string
}

variable "service_account" {
  description = "Kubernetes service account name"
  type        = string
}

variable "role_name" {
  description = "Name of the IAM role assumed by pods using this service account"
  type        = string
}

variable "policy_json" {
  description = "Inline IAM policy JSON attached to the role. Caller controls actions/resources/conditions."
  type        = string
}

variable "managed_policy_arns" {
  description = "Optional AWS-managed policy ARNs to also attach to the role"
  type        = list(string)
  default     = []
}

variable "cluster_oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider. When set together with cluster_oidc_issuer_url, the role also trusts IRSA (sts:AssumeRoleWithWebIdentity) and the SA gets the eks.amazonaws.com/role-arn annotation. Needed for tools that predate Pod Identity. Leave null for Pod-Identity-only."
  type        = string
  default     = null
}

variable "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL of the cluster (required when cluster_oidc_provider_arn is set)."
  type        = string
  default     = null
}

variable "create_namespace" {
  description = "Whether this module creates the Kubernetes namespace. Set false if managed elsewhere (e.g. Helm chart)."
  type        = bool
  default     = true
}

variable "create_service_account" {
  description = "Whether this module creates the Kubernetes service account. Set false if managed elsewhere."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Extra tags merged on top of the provider's default_tags. Do not duplicate default_tags here."
  type        = map(string)
  default     = {}
}
