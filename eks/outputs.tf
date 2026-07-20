output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.k8s.name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint URL"
  value       = aws_eks_cluster.k8s.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded CA certificate of the EKS API server"
  value       = aws_eks_cluster.k8s.certificate_authority[0].data
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL of the EKS cluster (used for IRSA)"
  value       = aws_eks_cluster.k8s.identity[0].oidc[0].issuer
}

output "cluster_security_group_id" {
  description = "Security group created by EKS for control plane <-> data plane communication"
  value       = aws_eks_cluster.k8s.vpc_config[0].cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider for the cluster (use as IRSA trust principal)"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "eks_node_role_name" {
  description = "Name of the IAM role assumed by EKS Auto Mode nodes (consumers can attach extra policies)"
  value       = aws_iam_role.node.name
}

