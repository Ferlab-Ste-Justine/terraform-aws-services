# pg-rds-kms-keys module

Creates a customer-managed KMS key (and alias) dedicated to encrypting an RDS
instance's storage and related data. Pass the resulting ARN to `pg-rds-instance`
(`storage.kms_key_arn`).

## Inputs

| Name | Type | Required | Notes |
|---|---|:---:|---|
| `rds_instance_identifier` | `string` | yes | RDS instance name — used to derive the key alias |
| `account_id` | `string` | yes | AWS account ID |
| `region` | `string` | no | AWS region (default `ca-central-1`) |

## Outputs

| Name | Description |
|---|---|
| `kms_key_arn` | ARN of the KMS key (sensitive) |
