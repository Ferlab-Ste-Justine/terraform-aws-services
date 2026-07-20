# eks_pod_identity module

Wires a Kubernetes **service account** to an **IAM role** via [EKS Pod
Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html)
so pods using the SA can call AWS APIs scoped by IAM. EKS Auto Mode includes
the Pod Identity Agent automatically — no addon to install.

## What it creates

- **`kubernetes_namespace`** *(optional, `create_namespace = true` default)*
- **`kubernetes_service_account`** *(optional, `create_service_account = true` default)*
- **`aws_iam_role`** with a trust policy locked to Pod Identity from this
  cluster only (`aws:SourceAccount` + `aws:SourceArn` conditions)
- **`aws_iam_role_policy`** with the caller-supplied `policy_json`
- **`aws_iam_role_policy_attachment`** for any extra managed-policy ARNs
- **`aws_eks_pod_identity_association`** linking the cluster + namespace +
  service account → IAM role

The module has **no cluster-level resources**, so it can be called many
times in the same root config (one per pod-identity binding).

## Inputs

| Name | Type | Default | Notes |
|---|---|---|---|
| `cluster_name` | `string` | — | required |
| `account_id` | `string` | — | required (trust policy condition) |
| `region` | `string` | — | required (trust policy condition) |
| `namespace` | `string` | — | required |
| `service_account` | `string` | — | required |
| `role_name` | `string` | — | required, IAM role name |
| `policy_json` | `string` | — | required, inline IAM policy JSON |
| `managed_policy_arns` | `list(string)` | `[]` | extra AWS-managed policies |
| `create_namespace` | `bool` | `true` | gate the k8s namespace creation |
| `create_service_account` | `bool` | `true` | gate the k8s SA creation |
| `tags` | `map(string)` | `{}` | applied to IAM role + Pod Identity association |

## Outputs

| Name | Description |
|---|---|
| `role_arn` | ARN of the IAM role |
| `role_name` | Name of the IAM role |
| `namespace` | Echo of the namespace |
| `service_account` | Echo of the SA name |
