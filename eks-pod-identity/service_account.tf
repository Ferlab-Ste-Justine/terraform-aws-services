resource "kubernetes_service_account_v1" "pod_identity" {
  count = var.create_service_account ? 1 : 0

  metadata {
    name      = var.service_account
    namespace = var.namespace
    # IRSA annotation is added only when cluster_oidc_provider_arn is set.
    # Tools that predate Pod Identity will use IRSA via this annotation; tools
    # that support Pod Identity ignore it and use the association instead.
    annotations = local.enable_irsa ? {
      "eks.amazonaws.com/role-arn" = aws_iam_role.pod_identity.arn
    } : {}
  }

  depends_on = [kubernetes_namespace_v1.pod_identity]
}
