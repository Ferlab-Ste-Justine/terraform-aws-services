locals {
  admin_policies = [
    "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy",
    "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  ]
}

data "aws_caller_identity" "current" {}
