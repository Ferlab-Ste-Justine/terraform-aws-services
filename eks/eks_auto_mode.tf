resource "aws_eks_cluster" "k8s" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.k8s_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = var.cluster_additional_security_group_ids
    endpoint_private_access = true
    endpoint_public_access  = false
    # public_access_cidrs deliberately omitted: dormant when public access
    # is off, and AWS preserves whatever is set when the attribute is not
    # in the resource block. Recovery scenario (need API publicly):
    # `aws eks update-cluster-config --resources-vpc-config
    # endpointPublicAccess=true,publicAccessCidrs=<your-ip>/32` directly.
    # Terraform will revert endpointPublicAccess to false on next apply
    # but won't touch the CIDRs you set manually.
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }

  bootstrap_self_managed_addons = false

  # Defaults to ["audit"] in variables.tf - the minimum required for
  # traceability of the Confidentiel data classification. Other log
  # types stay off to keep CloudWatch Logs spend predictable.
  enabled_cluster_log_types = var.enabled_cluster_log_types

  zonal_shift_config {
    enabled = var.zonal_shift_enabled
  }

  compute_config {
    enabled       = true
    node_pools    = var.builtin_node_pools
    node_role_arn = length(var.builtin_node_pools) > 0 ? aws_iam_role.node.arn : null
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }

  tags = var.tags
}

resource "aws_iam_role" "cluster" {
  name = var.eks_cluster_role_name

  assume_role_policy = data.aws_iam_policy_document.cluster_role_assume_role_policy.json

  tags = merge(var.tags, {
    "eks:eks-cluster-name" = var.cluster_name
  })
}

resource "aws_iam_role_policy_attachments_exclusive" "cluster" {
  role_name = aws_iam_role.cluster.name
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSComputePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  ]
}

data "aws_iam_policy_document" "cluster_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "tagging_inline_policy" {
  statement {
    sid    = "Compute"
    effect = "Allow"

    actions = [
      "ec2:CreateFleet",
      "ec2:RunInstances",
      "ec2:CreateLaunchTemplate"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = ["$${aws:PrincipalTag/eks:eks-cluster-name}"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/eks:kubernetes-node-class-name"
      values   = ["*"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/eks:kubernetes-node-pool-name"
      values   = ["*"]
    }
  }

  statement {
    sid    = "Storage"
    effect = "Allow"

    actions = [
      "ec2:CreateVolume",
      "ec2:CreateSnapshot"
    ]

    resources = [
      "arn:aws:ec2:*:*:volume/*",
      "arn:aws:ec2:*:*:snapshot/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = ["$${aws:PrincipalTag/eks:eks-cluster-name}"]
    }
  }

  statement {
    sid    = "Networking"
    effect = "Allow"

    actions   = ["ec2:CreateNetworkInterface"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = ["$${aws:PrincipalTag/eks:eks-cluster-name}"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/eks:kubernetes-cni-node-name"
      values   = ["*"]
    }
  }

  statement {
    sid    = "LoadBalancer"
    effect = "Allow"

    actions = [
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateRule",
      "ec2:CreateSecurityGroup"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = ["$${aws:PrincipalTag/eks:eks-cluster-name}"]
    }
  }

  statement {
    sid    = "ShieldProtection"
    effect = "Allow"

    actions   = ["shield:CreateProtection"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = ["$${aws:PrincipalTag/eks:eks-cluster-name}"]
    }
  }

  statement {
    sid    = "ShieldTagResource"
    effect = "Allow"

    actions   = ["shield:TagResource"]
    resources = ["arn:aws:shield::*:protection/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = ["$${aws:PrincipalTag/eks:eks-cluster-name}"]
    }
  }
}

resource "aws_iam_role_policy" "cluster_inline_policy" {
  name   = "Tagging_policy"
  role   = aws_iam_role.cluster.name
  policy = data.aws_iam_policy_document.tagging_inline_policy.json
}


resource "aws_iam_role" "node" {
  name = var.eks_node_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(var.tags, {
    "eks:eks-cluster-name" = var.cluster_name
  })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodeMinimalPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryPullOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.node.name
}
