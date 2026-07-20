resource "aws_db_instance" "service" {
  identifier                            = var.rds_instance_identifier
  engine                                = "postgres"
  engine_version                        = var.postgres_version
  publicly_accessible                   = var.networking.publicly_accessible
  multi_az                              = var.zones.multi_az
  instance_class                        = var.rds_instance_class
  
  performance_insights_enabled          = var.performance_insights.enabled
  performance_insights_kms_key_id       = var.performance_insights.kms_key_id != "" ? var.performance_insights.kms_key_id : null
  performance_insights_retention_period = var.performance_insights.retention_period

  # Storage
  storage_type          = var.storage.type
  max_allocated_storage = var.storage.max_allocated
  allocated_storage     = var.storage.allocated
  storage_encrypted     = var.storage.kms_key_arn != ""
  kms_key_id            = var.storage.kms_key_arn != "" ? var.storage.kms_key_arn : null

  # Admin credentials
  username          = var.admin_credentials.username
  password          = var.admin_credentials.password

  # Snapshot configuration
  skip_final_snapshot       = var.snapshots.skip_on_deletion
  final_snapshot_identifier = !var.snapshots.skip_on_deletion ? "${var.rds_instance_identifier}-on-deletion-snapshot" : null
  backup_window             = var.snapshots.daily_window != "" ? var.snapshots.daily_window : null
  backup_retention_period   = var.snapshots.retention_period

  # Maintenance
  maintenance_window         = var.maintenance.window
  auto_minor_version_upgrade = var.maintenance.upgrade_minor_version

  # Monitoring
  monitoring_interval = var.enhanced_monitoring.interval
  monitoring_role_arn = var.enhanced_monitoring.role_arn

  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = local.rds_security_group_ids
  availability_zone      = !var.zones.multi_az && var.zones.availability_zone != "" ? var.zones.availability_zone : null
}