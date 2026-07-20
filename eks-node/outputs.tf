output "nodepool_name" {
  description = "Name of the Karpenter NodePool created by this module"
  value       = var.nodepool_name
}

output "nodeclass_name" {
  description = "Name of the EKS Auto Mode NodeClass created by this module"
  value       = var.nodeclass_name
}
