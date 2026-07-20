locals {
  # Enable IRSA in addition to Pod Identity when the OIDC inputs are set.
  # Some tools predate Pod Identity and only know how to read IRSA-style auth,
  # so the role needs to trust both when those tools are in play.
  enable_irsa       = var.cluster_oidc_provider_arn != null && var.cluster_oidc_issuer_url != null
  oidc_url_no_https = local.enable_irsa ? replace(var.cluster_oidc_issuer_url, "https://", "") : ""

  pod_identity_statement = {
    Effect = "Allow"
    Principal = {
      Service = "pods.eks.amazonaws.com"
    }
    Action = ["sts:AssumeRole", "sts:TagSession"]
    Condition = {
      StringEquals = {
        "aws:SourceAccount" = var.account_id
      }
      ArnLike = {
        "aws:SourceArn" = "arn:aws:eks:${var.region}:${var.account_id}:cluster/${var.cluster_name}"
      }
    }
  }

  irsa_statements = local.enable_irsa ? [{
    Effect = "Allow"
    Principal = {
      Federated = var.cluster_oidc_provider_arn
    }
    Action = "sts:AssumeRoleWithWebIdentity"
    Condition = {
      StringEquals = {
        "${local.oidc_url_no_https}:sub" = "system:serviceaccount:${var.namespace}:${var.service_account}"
        "${local.oidc_url_no_https}:aud" = "sts.amazonaws.com"
      }
    }
  }] : []
}

resource "aws_iam_role" "pod_identity" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = concat([local.pod_identity_statement], local.irsa_statements)
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "pod_identity" {
  name   = "${var.role_name}-policy"
  role   = aws_iam_role.pod_identity.id
  policy = var.policy_json
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each   = toset(var.managed_policy_arns)
  role       = aws_iam_role.pod_identity.name
  policy_arn = each.value
}

resource "aws_eks_pod_identity_association" "pod_identity" {
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account
  role_arn        = aws_iam_role.pod_identity.arn

  tags = var.tags

  depends_on = [kubernetes_service_account_v1.pod_identity]
}
