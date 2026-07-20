# pg-rds-instance module

Provisions a PostgreSQL RDS instance together with its networking (dedicated
security group and DB subnet group). Snapshots, storage, multi-AZ, performance
insights, maintenance and enhanced monitoring are all tunable via grouped object
variables with sane defaults.

## Inputs

| Name | Type | Required | Notes |
|---|---|:---:|---|
| `rds_instance_identifier` | `string` | yes | RDS instance name |
| `account_id` | `string` | yes | AWS account ID |
| `admin_credentials` | `object` (sensitive) | yes | `{ username = "root", password }` — root credentials |
| `networking` | `object` | yes | `{ subnet_ids, access_control{existing_sg_ids, allowed_sg_ids}, publicly_accessible }` |
| `region` | `string` | no | AWS region (default `ca-central-1`) |
| `vpc_id` | `string` | no | VPC ID (needed for the security group) |
| `postgres_version` | `string` | no | Default `14` |
| `rds_instance_class` | `string` | no | Default `db.m6i.xlarge` |
| `storage` | `object` | no | `{ type, allocated, max_allocated, kms_key_arn }` |
| `snapshots` | `object` | no | `{ skip_on_deletion, daily_window, retention_period }` |
| `zones` | `object` | no | `{ multi_az, availability_zone }` |
| `performance_insights` | `object` | no | `{ enabled, retention_period, kms_key_id }` |
| `maintenance` | `object` | no | `{ window, upgrade_minor_version }` |
| `enhanced_monitoring` | `object` | no | `{ interval, role_arn }` — role_arn from `pg-rds-global-iam` |

## Outputs

| Name | Description |
|---|---|
| `rds_endpoint` | Connection endpoint of the RDS instance |
| `rds_arn` | ARN of the RDS instance |
