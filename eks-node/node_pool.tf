resource "kubernetes_manifest" "karpenter_nodepool" {
  manifest = {
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = var.nodepool_name
    }
    spec = {
      disruption = {
        consolidationPolicy = "WhenEmptyOrUnderutilized"
        consolidateAfter    = var.consolidate_after
      }
      template = {
        metadata = {
          labels = var.labels
        }
        spec = {
          nodeClassRef = {
            group = "eks.amazonaws.com"
            kind  = "NodeClass"
            name  = var.nodeclass_name
          }
          requirements = concat(
            [
              {
                key      = "eks.amazonaws.com/instance-category"
                operator = "In"
                values   = var.instance_categories
              },
              {
                key      = "kubernetes.io/arch"
                operator = "In"
                values   = var.architecture
              },
              {
                key      = "karpenter.sh/capacity-type"
                operator = "In"
                values   = var.capacity_type
              },
            ],
            length(var.topology_zones) > 0 ? [
              {
                key      = "topology.kubernetes.io/zone"
                operator = "In"
                values   = var.topology_zones
              }
            ] : []
          )
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.karpenter_nodeclass]
}
