locals {
  nodeclass_pod_networking = length(var.pod_subnet_ids) > 0 ? {
    podSubnetSelectorTerms        = [for subnet in var.pod_subnet_ids : { id = subnet }]
    podSecurityGroupSelectorTerms = [for security_group in var.pod_security_group_ids : { id = security_group }]
  } : {}

  nodeclass_advanced_networking = var.ipv4_prefix_size != null ? {
    advancedNetworking = {
      ipv4PrefixSize = var.ipv4_prefix_size
    }
  } : {}
}

resource "kubernetes_manifest" "karpenter_nodeclass" {
  manifest = {
    apiVersion = "eks.amazonaws.com/v1"
    kind       = "NodeClass"
    metadata = {
      name = var.nodeclass_name
    }
    spec = merge({
      ephemeralStorage       = var.ephemeral_storage
      networkPolicy          = "DefaultAllow"
      networkPolicyEventLogs = "Disabled"
      role                   = var.eks_node_role_name
      securityGroupSelectorTerms = concat(
        [{ id = var.cluster_security_group_id }],
        var.external_node_security_group_id != null ? [{ id = var.external_node_security_group_id }] : []
      )
      snatPolicy = "Random"
      subnetSelectorTerms = [for subnet in var.private_subnet_ids : {
        id = subnet
      }]
      tags = merge(var.tags, {
        Name                             = var.nodeclass_name
        "eks:eks-cluster-name"           = var.cluster_name
        "eks:kubernetes-node-class-name" = var.nodeclass_name
        "eks:kubernetes-node-pool-name"  = var.nodepool_name
      })
      },
      local.nodeclass_pod_networking,
      local.nodeclass_advanced_networking,
    )
  }

  lifecycle {
    precondition {
      condition     = (length(var.pod_subnet_ids) > 0) == (length(var.pod_security_group_ids) > 0)
      error_message = "pod_subnet_ids and pod_security_group_ids must be set together: EKS Auto Mode rejects one without the other."
    }
  }
}
