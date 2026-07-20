resource "aws_eks_access_entry" "system_admin_access_entry" {
  cluster_name      = var.cluster_name
  principal_arn     = var.eks_admin_role_arn
  type              = "STANDARD"
  kubernetes_groups = []

  tags = var.tags

  depends_on = [aws_eks_cluster.k8s]
}

resource "aws_eks_access_policy_association" "system_admin_policies" {
  for_each      = toset(local.admin_policies)
  cluster_name  = var.cluster_name
  policy_arn    = each.value
  principal_arn = var.eks_admin_role_arn

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_cluster.k8s
  ]
}
