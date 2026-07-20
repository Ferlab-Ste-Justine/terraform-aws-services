resource "aws_iam_openid_connect_provider" "eks" {
  url            = aws_eks_cluster.k8s.identity[0].oidc[0].issuer
  client_id_list = ["sts.amazonaws.com"]
  // Thumbprint set at cluster bootstrap. oidc.eks.ca-central-1.amazonaws.com
  // is not resolvable from the pipeline VPC so dynamic fetching via
  // data "tls_certificate" is not viable. ignore_changes prevents pipeline
  // applies from attempting to update this value.
  thumbprint_list = ["06b25927c42a721631c1efd9431e648fa62e1e39"]

  lifecycle {
    ignore_changes = [thumbprint_list]
  }
}
