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
| `networking` | `object` | yes | `{ subnet_ids, access_control{allowed_ingress{sg_ids, subnet}, apply_existing_sg_ids}, publicly_accessible }` |
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

`access_control` decides what is allowed to reach 5432. Nothing in it is
exclusive: the options combine.

- `apply_existing_sg_ids` — security groups you manage yourself, attached to the
  instance as-is. The module adds no rule to them.
- `allowed_ingress.sg_ids` — the module creates its own security group and
  authorises these security groups on 5432.
- `allowed_ingress.subnet` — the module also authorises the CIDRs of
  `subnet_ids`. Defaults to `false`.

When `allowed_ingress` asks for anything, the module creates one security group
for it and attaches it **in addition to** `apply_existing_sg_ids`.

Leaving every option empty is rejected at plan time: a database nothing can
reach is almost certainly not what the caller wants.

### Moving clients from one source to another

A security group that is not yet attached to any network interface authorises
nothing, so switching in one step cuts every existing client. Authorise both
sources, move the clients, then drop the one you no longer need:

```
access_control = {
  allowed_ingress = { subnet = true }                          # before
  allowed_ingress = { subnet = true, sg_ids = ["sg-..."] }     # during
  allowed_ingress = { sg_ids = ["sg-..."] }                    # after
}
```

Ingress and egress are declared as `aws_vpc_security_group_*_rule` resources
rather than inline blocks, so adding a source does not revoke the others first.
