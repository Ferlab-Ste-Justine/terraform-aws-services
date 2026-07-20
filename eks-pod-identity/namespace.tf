resource "kubernetes_namespace_v1" "pod_identity" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
    labels = {
      scope = "application"
    }
  }
}
