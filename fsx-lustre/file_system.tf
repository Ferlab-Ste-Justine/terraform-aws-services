# FSx Lustre PERSISTENT_2 with the SSD storage class. SSD (not
# Intelligent-Tiering) because Data Repository Associations are not
# supported on IT - AWS rejects them at create time with
# `UnsupportedOperation: Cannot create data repository association for
# file system with 'INTELLIGENT_TIERING' storage type.` IT uses S3 as an
# internal tier and won't expose a customer-managed bucket.
#
# On SSD, throughput is tied to capacity: baseline = capacity x
# per_unit_storage_throughput / 1024 MBps. The 500 MB/s/TiB tier at
# 4.8 TiB gives ~2.4 GB/s baseline with generous burst on top.
#
# DRAs (s3://ref/, s3://inputs/, s3://outputs/) are attached separately
# in data_repositories.tf via for_each.

resource "aws_fsx_lustre_file_system" "fs" {
  deployment_type             = "PERSISTENT_2"
  storage_type                = "SSD"
  storage_capacity            = var.storage_capacity
  per_unit_storage_throughput = var.per_unit_storage_throughput
  file_system_type_version    = "2.15"
  data_compression_type       = var.data_compression_type

  subnet_ids         = [var.subnet_id]
  security_group_ids = var.security_group_ids

  # No automatic snapshots - data is mirrored to S3 via the DRAs, which
  # is the durable copy. Final-on-delete is also skipped for the same
  # reason; this matters when terraform destroys the FS.
  automatic_backup_retention_days = 0
  skip_final_backup               = true

  tags = merge(var.tags, {
    Name = var.file_system_name
  })

  # The FSx API doesn't return security_group_ids on Read, so the provider
  # always reports drift on this attribute. Lock it in to avoid noisy plans.
  lifecycle {
    ignore_changes = [security_group_ids]
  }
}
