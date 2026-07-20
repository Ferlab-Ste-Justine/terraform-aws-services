# s3_bucket module

Generic S3 bucket with sane defaults: versioning enabled, SSE-S3 encryption,
all public access blocked, incomplete multipart uploads aborted after 7
days. Reusable for any S3 use case (S3 Files backing, app data, logs, etc.).

## Inputs

| Name | Type | Required | Notes |
|---|---|:---:|---|
| `name` | `string` | yes | bucket name (globally unique) |
| `force_destroy` | `bool` | no | default `false`; set `true` for QA |
| `tags` | `map(string)` | no | applied to the bucket |

## Outputs

| Name | Description |
|---|---|
| `name` / `id` | bucket name |
| `arn` | bucket ARN (consumed by callers like `s3_files`) |
