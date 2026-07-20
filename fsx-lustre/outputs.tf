output "file_system_id" {
  description = "FSx Lustre file system ID. Used as the volumeHandle in static PVs."
  value       = aws_fsx_lustre_file_system.fs.id
}

output "file_system_arn" {
  description = "ARN of the FSx Lustre file system."
  value       = aws_fsx_lustre_file_system.fs.arn
}

output "dns_name" {
  description = "DNS name of the file system. Surface this as the `dnsname` volumeAttribute on the PV."
  value       = aws_fsx_lustre_file_system.fs.dns_name
}

output "mount_name" {
  description = "Lustre mount name. Surface this as the `mountname` volumeAttribute on the PV."
  value       = aws_fsx_lustre_file_system.fs.mount_name
}

output "network_interface_ids" {
  description = "Set of ENI IDs the file system is reachable through."
  value       = aws_fsx_lustre_file_system.fs.network_interface_ids
}

output "data_repository_association_ids" {
  description = "Map of DRA logical name to AWS-side DRA ID."
  value       = { for k, v in aws_fsx_data_repository_association.dra : k => v.id }
}
