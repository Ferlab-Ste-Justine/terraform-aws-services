resource "kubernetes_manifest" "karpenter_nodeclass" {
  manifest = {
    apiVersion = "eks.amazonaws.com/v1"
    kind       = "NodeClass"
    metadata = {
      name = var.nodeclass_name
    }
    spec = {
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
    }
  }
}
