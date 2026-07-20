# eks_node module

Adds the AWS-side and Kubernetes-side resources needed to run custom node
pools on an existing EKS Auto Mode cluster:

- **`aws_iam_openid_connect_provider`** — IAM OIDC provider derived from the
  cluster's OIDC issuer. Used by IRSA-based addons (AWS Load Balancer
  Controller, external-dns, etc.) even though Auto Mode prefers Pod Identity.
- **`aws_ec2_tag` (one per private subnet)** — sets
  `kubernetes.io/role/internal-elb = "1"` so the AWS Load Balancer Controller
  can discover subnets when creating internal NLBs/ALBs.
- **`kubectl_manifest.karpenter_nodeclass`** — EKS Auto Mode native NodeClass
  (`apiVersion: eks.amazonaws.com/v1`) with subnet/SG selectors, ephemeral
  storage, and tags.
- **`kubectl_manifest.karpenter_nodepool`** — Karpenter NodePool
  (`apiVersion: karpenter.sh/v1`) referencing the NodeClass and constraining
  instance category, architecture, and capacity type.

## Single-pass deploy

This module is designed to be applied in the **same `terraform apply`** as the
EKS cluster itself — no `deploy_phase_2` flag, no second pass. That works
because:

1. Cluster details (`cluster_name`, `cluster_security_group_id`,
   `cluster_oidc_issuer_url`) are passed as **input variables** rather than
   discovered via data sources, so plan-time evaluation does not require the
   cluster to exist yet.
2. The `gavinbunney/kubectl` provider configures lazily — it does not phone
   the cluster at plan time. As long as the parent module configures
   `provider "kubectl"` with computed values from the EKS module's outputs,
   Terraform sequences cluster creation before any `kubectl_manifest.apply()`.
3. `data.tls_certificate.eks` reads the OIDC issuer URL at apply time, after
   the cluster exists.

## Inputs

| Name | Type | Default | Required |
|------|------|---------|:--------:|
| `cluster_name` | `string` | — | yes |
| `cluster_security_group_id` | `string` | — | yes |
| `cluster_oidc_issuer_url` | `string` | — | yes |
| `private_subnet_ids` | `list(string)` | — | yes |
| `eks_node_role_name` | `string` | — | yes |
| `nodepool_name` | `string` | — | yes |
| `nodeclass_name` | `string` | — | yes |
| `capacity_type` | `list(string)` | — | yes |
| `instance_categories` | `list(string)` | — | yes |
| `architecture` | `list(string)` | — | yes |
| `tags` | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `nodepool_name` | Echo of the NodePool name |
| `nodeclass_name` | Echo of the NodeClass name |
| `oidc_provider_arn` | ARN of the IAM OIDC provider (use as IRSA trust principal) |
