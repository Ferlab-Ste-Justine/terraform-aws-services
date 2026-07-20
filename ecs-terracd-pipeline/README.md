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

`task` object: `container_image` (default `ferlabcrsj/terracd-aws:v0.2.0`), `cpu`
(512), `memory` (1024), `execution_role_arn`, `task_role_arn`,
`environment_variables`, `terracd_config` (terracd config file content),
`git_auth.http.{username, password_secret_arn}` (optional), `git_trusted_signing_keys`
(optional list), `metrics_enabled` (default `false`, adds the sigv4 proxy sidecar).

`scheduler` object: `schedule_expression` (default `rate(15 minutes)`),
`max_retry_attempts` (default 0), `esc_cluster_arn`, `subnets`, `security_groups`.

## Outputs

None.
