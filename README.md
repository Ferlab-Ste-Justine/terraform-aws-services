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

# Provenance

These modules were extracted from [`qlin-qa-infra`](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra),
where they lived inline. History prior to this repo is traced below — each row
links to the module's exact original location, pinned at the commit it was
extracted from. Run `git log <commit> -- <path>` in `qlin-qa-infra` for the full
history.

| Module | Original location | Extracted from commit |
| --- | --- | --- |
| `eks` | [terraform/kubernetes/eks](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra/tree/c713612277c60cb32d4658f147f6200991cfea7c/terraform/kubernetes/eks) | [`c713612`](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra/commit/c713612277c60cb32d4658f147f6200991cfea7c) |
| `fsx-lustre` | [terraform/lustre/fsx_lustre](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra/tree/a12e6c3a22ca6b4887debea72545ea3390432f44/terraform/lustre/fsx_lustre) | [`a12e6c3`](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra/commit/a12e6c3a22ca6b4887debea72545ea3390432f44) |
| `ecs-terracd-pipeline` | [terraform/modules/ecs-terracd-pipeline](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra/tree/2c5501839b964d66317285deea336e17fa953c54/terraform/modules/ecs-terracd-pipeline) | [`2c55018`](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra/commit/2c5501839b964d66317285deea336e17fa953c54) |
| `eks-node` | [terraform/modules/eks_node](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra/tree/0cb26e3beed40a573c4fd7bf7e157a310c1b4f4c/terraform/modules/eks_node) | [`0cb26e3`](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra/commit/0cb26e3beed40a573c4fd7bf7e157a310c1b4f4c) |
| `eks-pod-identity` | [terraform/modules/eks_pod_identity](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra/tree/0b59aad8d46107295fb539795d13e7e58347be80/terraform/modules/eks_pod_identity) | [`0b59aad`](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra/commit/0b59aad8d46107295fb539795d13e7e58347be80) |
| `s3-bucket` | [terraform/modules/s3_bucket](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra/tree/68d69f274504bc3960be1fa92b4e192b7ebe3bee/terraform/modules/s3_bucket) | [`68d69f2`](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra/commit/68d69f274504bc3960be1fa92b4e192b7ebe3bee) |
| `tf-backend` | [terraform/modules/tf-backend](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra/tree/e671c415b34f307e6fffbbc0d74003ed6aeb7fa9/terraform/modules/tf-backend) | [`e671c41`](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra/commit/e671c415b34f307e6fffbbc0d74003ed6aeb7fa9) |
| `pg-database` | [terraform/postgres/configuration/pg-database](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra/tree/e1cdbdca400a8afe87b5fed11c136e0646f09858/terraform/postgres/configuration/pg-database) | [`e1cdbdc`](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra/commit/e1cdbdca400a8afe87b5fed11c136e0646f09858) |
| `pg-rds-global-iam` | [terraform/postgres/rds/pg-rds-global-iam](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra/tree/e1cdbdca400a8afe87b5fed11c136e0646f09858/terraform/postgres/rds/pg-rds-global-iam) | [`e1cdbdc`](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra/commit/e1cdbdca400a8afe87b5fed11c136e0646f09858) |
| `pg-rds-instance` | [terraform/postgres/rds/pg-rds-instance](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra/tree/591e663c988677783b35e8b7eda89e2443079e17/terraform/postgres/rds/pg-rds-instance) | [`591e663`](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra/commit/591e663c988677783b35e8b7eda89e2443079e17) |
| `pg-rds-kms-keys` | [terraform/secrets/pg-rds-kms-keys](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra/tree/591e663c988677783b35e8b7eda89e2443079e17/terraform/secrets/pg-rds-kms-keys) | [`591e663`](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra/commit/591e663c988677783b35e8b7eda89e2443079e17) |
| `rds-role-secret` | [terraform/secrets/rds-role-secret](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra/tree/bdc43d3502abcfc1fd186e54a497f0c6c63430ea/terraform/secrets/rds-role-secret) | [`bdc43d3`](https://github.com/Ferlab-Ste-Justine/qlin-qa-infra/commit/bdc43d3502abcfc1fd186e54a497f0c6c63430ea) |
