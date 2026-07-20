# tf-backend module

Creates the AWS resources required for a Terraform S3 remote state backend:
one S3 bucket (versioned, AES256, public-access blocked, incomplete-upload
abort rule) and one DynamoDB table for state locking.

## Inputs

| Name | Type | Required | Notes |
|---|---|:---:|---|
| `pipeline_name` | `string` | yes | short name used in resource names (e.g. `rds`, `starrocks`) |
| `account_id` | `string` | yes | AWS account ID — appended to bucket name for global uniqueness |
| `region` | `string` | yes | AWS region — appended to bucket name for global uniqueness |

## Outputs

| Name | Description |
|---|---|
| `bucket_name` | S3 bucket name |
| `dynamodb_table_name` | DynamoDB table name |

## Resource naming

- S3 bucket: `<pipeline_name>-tfstate-<account_id>-<region>`
- DynamoDB table: `<pipeline_name>-tflock`
