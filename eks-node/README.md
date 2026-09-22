# eks_node module

Adds the Kubernetes-side resources needed to run a custom node pool on an
existing EKS Auto Mode cluster:

- **`kubernetes_manifest.karpenter_nodeclass`** — EKS Auto Mode native NodeClass
  (`apiVersion: eks.amazonaws.com/v1`) with subnet/SG selectors, ephemeral
  storage, pod networking, and tags.
- **`kubernetes_manifest.karpenter_nodepool`** — Karpenter NodePool
  (`apiVersion: karpenter.sh/v1`) referencing the NodeClass and constraining
  instance category, architecture, and capacity type.

## Inputs

| Name | Type | Default | Required |
|------|------|---------|:--------:|
| `cluster_name` | `string` | — | yes |
| `cluster_security_group_id` | `string` | — | yes |
| `private_subnet_ids` | `list(string)` | — | yes |
| `eks_node_role_name` | `string` | — | yes |
| `nodepool_name` | `string` | — | yes |
| `nodeclass_name` | `string` | — | yes |
| `capacity_type` | `list(string)` | — | yes |
| `instance_categories` | `list(string)` | — | yes |
| `architecture` | `list(string)` | — | yes |
| `external_node_security_group_id` | `string` | `null` | no |
| `ephemeral_storage` | `object` | 80Gi / 3000 iops / 125 MBps | no |
| `labels` | `map(string)` | `{}` | no |
| `topology_zones` | `list(string)` | `[]` | no |
| `consolidate_after` | `string` | `"5m"` | no |
| `tags` | `map(string)` | `{}` | no |
| `ipv4_prefix_size` | `string` | `null` | no |
| `pod_networking` | `object` | `null` | no |

## Pod networking

`ipv4_prefix_size` picks how pod IPs are drawn from the subnet. The EKS default
delegates a `/28` prefix per node, reserving 16 addresses up front and adding
another `/28` whenever demand exceeds the current block. `"32"` allocates one
address per pod instead, at the cost of slower pod-creation velocity. Use it
where the subnet is small relative to the node count.

Leave the variable null rather than setting `"Auto"` to get the default: an
explicit value makes Terraform's field manager take ownership of the field, and
relinquishing it later rolls the fleet again.

`pod_networking` moves pod IPs off the node subnets: the node's primary ENI keeps
the node subnet and security groups and carries only the node's own address,
while EKS Auto Mode creates secondary ENIs in the pod subnets. This is the Auto
Mode equivalent of VPC CNI custom networking, which relies on an `ENIConfig` CRD
that Auto Mode does not expose.

Pod security groups apply to traffic inside the VPC only. With the module's
`snatPolicy = "Random"`, traffic leaving the VPC is translated to the node's
address and the node security groups apply instead. Any existing rule that
authorises pod traffic by node-subnet CIDR therefore has to be extended to the
pod subnets before switching over.

Both fields change the NodeClass spec, which drifts every node using it: EKS Auto
Mode then replaces the whole fleet. Plan the change like a rolling restart.

## Outputs

| Name | Description |
|------|-------------|
| `nodepool_name` | Echo of the NodePool name |
| `nodeclass_name` | Echo of the NodeClass name |
