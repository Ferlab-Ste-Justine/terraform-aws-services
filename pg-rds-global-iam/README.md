# pg-rds-global-iam module

Creates the account-wide IAM role that RDS uses to publish Enhanced Monitoring
metrics to CloudWatch (`monitoring.rds.amazonaws.com`, managed policy
`AmazonRDSEnhancedMonitoringRole`). Instantiate once per account and share its ARN
with every RDS instance that enables enhanced monitoring.

## Inputs

None.

## Outputs

| Name | Description |
|---|---|
| `rds_enhanced_monitoring_role_arn` | ARN of the enhanced-monitoring IAM role (pass to `pg-rds-instance`'s `enhanced_monitoring.role_arn`) |
