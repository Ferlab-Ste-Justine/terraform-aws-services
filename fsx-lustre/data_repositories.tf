# One DRA per entry in var.data_repository_associations.
#
# - batch_import_on_create=true triggers a metadata import task at
#   creation: every object in the bucket gets a stub entry in the FS so
#   `ls` shows them without a per-file round-trip. Recommended for the
#   reference dataset.
# - auto_import_events drives lazy materialization (file contents pulled
#   on first read after the metadata stub is touched).
# - auto_export_events drives write-back to S3. Use [NEW, CHANGED, DELETED]
#   on the outputs DRA so pipeline results land back in S3 automatically.

resource "aws_fsx_data_repository_association" "dra" {
  for_each = var.data_repository_associations

  file_system_id                   = aws_fsx_lustre_file_system.fs.id
  file_system_path                 = each.value.file_system_path
  data_repository_path             = each.value.data_repository_path
  batch_import_meta_data_on_create = each.value.batch_import_on_create

  s3 {
    dynamic "auto_import_policy" {
      for_each = length(each.value.auto_import_events) > 0 ? [1] : []
      content {
        events = each.value.auto_import_events
      }
    }

    dynamic "auto_export_policy" {
      for_each = length(each.value.auto_export_events) > 0 ? [1] : []
      content {
        events = each.value.auto_export_events
      }
    }
  }

  tags = merge(var.tags, {
    Name = "${var.file_system_name}-dra-${each.key}"
  })

  # AWS docs note DRA creation can take "up to an hour" - especially with
  # batch_import_meta_data_on_create=true on a populated bucket. The
  # provider default of 10m hits before AVAILABLE is reached. Same
  # ceiling for delete (the DRA must drain pending import/export work
  # before it's removed).
  timeouts {
    create = "60m"
    delete = "60m"
  }
}
