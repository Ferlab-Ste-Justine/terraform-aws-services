# ecs-terracd-pipeline module

Provisions a self-contained [terracd](https://github.com/Ferlab-Ste-Justine/terracd)
pipeline on ECS Fargate, triggered on a schedule by EventBridge Scheduler. Creates
the CloudWatch log group, the terracd entrypoint SSM parameter, the task role and
task definition, an optional task security group, and the scheduler (with its role
and dead-letter queue).

The caller provides the task role ARN and the terracd config; domain-specific IAM
stays in the calling stack.

## Inputs

| Name | Type | Required | Notes |
|---|---|:---:|---|
| `name` | `string` | yes | Pipeline name, used to derive resource names |
| `account_id` | `string` | yes | AWS account ID |
| `region` | `string` | yes | AWS region |
| `vpc_id` | `string` | no | VPC ID — required only when a task security group is created |
| `tags` | `map(string)` | no | Tags applied to all resources |
| `task` | `object` | yes | Task settings (see below) |
| `scheduler` | `object` | yes | Scheduler settings (see below) |

`task` object: `container_images` (default `{ terracd = "ferlabcrsj/terracd-aws:v0.3.0", sigv4_proxy = "public.ecr.aws/aws-observability/aws-sigv4-proxy:ed72b3" }`), `cpu`
(512), `memory` (1024), `execution_role_arn`, `task_role_arn`,
`environment_variables`, `terracd_config` (terracd config file content),
`git_auth.http.{username, password_secret_arn}` (optional), `git_trusted_signing_keys`
(optional list), `git_trusted_keys_ssm_prefix` (optional string), `metrics_enabled`
(default `false`, adds the sigv4 proxy sidecar).

Set `git_trusted_keys_ssm_prefix` to fetch the trusted signing keys from SSM at
startup instead of baking them into the task definition: the entrypoint writes
every parameter under the prefix to `/etc/terracd/git-trusted-keys/`, and the
module grants the task role read access to that prefix. Point the terracd config's
`gpg_public_keys_paths` at that directory - terracd walks it, so the config stays
static as keys are added or revoked, and a revocation takes effect on the next run
rather than on the next apply. The entrypoint exits non-zero when the prefix yields
no key, so terracd never runs without verifying signatures.

`scheduler` object: `schedule_expression` (default `rate(15 minutes)`),
`max_retry_attempts` (default 0), `esc_cluster_arn`, `subnets`, `security_groups`.

## Outputs

None.

## Notes

The CloudWatch log group's `kms_key_id` and `retention_in_days` are left to the
Landing Zone Accelerator (LZA) account controls (`ignore_changes`), so Terraform
does not strip LZA-applied encryption or retention on each run.
