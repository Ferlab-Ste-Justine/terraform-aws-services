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
| `networking` | `object` | yes | `{ subnet_ids, access_control{existing_sg_ids, allowed_sg_ids, allow_subnet_ingress}, publicly_accessible }` |
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

## Access control

`access_control` decides what is allowed to reach 5432.

- `existing_sg_ids` — attach the instance to security groups you manage yourself.
  The module then creates no security group and adds no rule.
- `allowed_sg_ids` — the module creates its security group and authorises those
  security groups.
- `allow_subnet_ingress` — whether the module also authorises the CIDRs of
  `subnet_ids`. Left unset it is on when `allowed_sg_ids` is empty and off
  otherwise, which is the historical behaviour.

Set `allow_subnet_ingress = true` alongside `allowed_sg_ids` to authorise both at
once. That matters when moving clients from one source to the other: a security
group that is not yet attached to any network interface authorises nothing, so
switching in a single step cuts every existing client. Authorise both, move the
clients, then drop the subnet CIDRs.

