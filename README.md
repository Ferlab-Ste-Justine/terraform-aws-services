# About

Reusable Terraform modules for AWS services, isolated from any single project so
they can be shared across environments (QA, production) and future projects while
keeping our orchestrations DRY.

Each module lives in its own top-level directory, following the same monorepo
layout as [terraform-cloudinit-templates](https://github.com/Ferlab-Ste-Justine/terraform-cloudinit-templates).

The repo is limited to AWS services (with lightweight service dependencies like the
postgres provider being acceptable). Full-blown virtualization modules (e.g.
StarRocks) are kept in their own repositories.

# Usage

Reference a module by its subdirectory and pin a tag:

```hcl
module "backend" {
  source = "git::https://github.com/Ferlab-Ste-Justine/terraform-aws-services.git//tf-backend?ref=v0.1.0"

  pipeline_name = "rds"
}
```

Always pin `?ref=<tag>`; never track a branch.

# Modules

| Module | Description |
| --- | --- |
| `eks` | EKS cluster in auto mode with the pod identity agent, OIDC provider and access entries. |
| `eks-node` | Custom EKS node class and node pool for auto mode. |
| `eks-pod-identity` | Namespace, service account and IAM role wired through EKS Pod Identity. |
| `s3-bucket` | S3 bucket with sane defaults. |
| `tf-backend` | S3 bucket and DynamoDB table for a Terraform remote state backend. |
| `ecs-terracd-pipeline` | ECS Fargate pipeline running terracd. |
| `fsx-lustre` | FSx for Lustre file system with data repository associations. |
| `pg-database` | Postgres role and database provisioning. |
| `pg-rds-global-iam` | Account-wide RDS IAM (enhanced monitoring role). |
| `pg-rds-instance` | RDS Postgres instance with its networking. |
| `pg-rds-kms-keys` | KMS keys for RDS encryption. |
| `rds-role-secret` | Generated RDS role password stored in Secrets Manager. |

Per-module documentation is being added incrementally.

# License

[Apache License 2.0](LICENSE)
