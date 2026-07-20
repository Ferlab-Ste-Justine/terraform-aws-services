# EKS module (Auto Mode)

Provisions an EKS cluster running in **Auto Mode** with:

- IAM role for the control plane (with the inline tagging policy required by EKS Auto Mode)
- IAM role for the EKS-managed nodes
- Access entry + policy associations for an admin IAM role
- SSM parameters publishing the cluster's CA data, API endpoint and SG id

## Tagging

The module exposes a single `tags` input (`map(string)`). It is applied to
every taggable resource the module creates. On the two IAM roles it is merged
with the functional `eks:eks-cluster-name` tag, which is **required** by the
inline tagging policy attached to the cluster role (the policy uses
`aws:PrincipalTag/eks:eks-cluster-name` in its conditions).

Pass the SQSS_* tags required by the AWS organization SCP via this map.

## Inputs

| Name | Type | Default | Required |
|------|------|---------|:--------:|
| `cluster_name` | `string` | — | yes |
| `eks_admin_role_arn` | `string` | — | yes |
| `eks_cluster_role_name` | `string` | — | yes |
| `eks_node_role_name` | `string` | — | yes |
| `region` | `string` | `"ca-central-1"` | no |
| `k8s_version` | `string` | `"1.35"` | no |
| `private_subnet_ids` | `list(string)` | `[]` | no |
| `builtin_node_pools` | `list(string)` | `[]` | no |
| `tags` | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `id_groupe_securite_control_plane` | Cluster security group used for control plane <-> data plane traffic |
