locals {
  use_existing_sgs    = length(var.networking.access_control.existing_sg_ids) > 0
  use_allowed_sgs     = !local.use_existing_sgs && length(var.networking.access_control.allowed_sg_ids) > 0
  use_subnet_fallback = !local.use_existing_sgs && !local.use_allowed_sgs

  rds_security_group_ids = local.use_existing_sgs ? var.networking.access_control.existing_sg_ids : [aws_security_group.rds[0].id]
}

data "aws_subnet" "rds" {
  for_each = local.use_subnet_fallback ? toset(var.networking.subnet_ids) : toset([])
  id       = each.value
}

resource "aws_security_group" "rds" {
  count = !local.use_existing_sgs ? 1 : 0

  name        = "${var.rds_instance_identifier}-rds"
  description = "Security group for ${var.rds_instance_identifier} RDS instance"
  vpc_id      = var.vpc_id

  //Note: Might not be needed. Keeping it for now.
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = local.use_allowed_sgs ? [1] : []
    content {
      description     = "Allow Postgres from allowed security groups"
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      security_groups = var.networking.access_control.allowed_sg_ids
    }
  }

  dynamic "ingress" {
    for_each = local.use_subnet_fallback ? [1] : []
    content {
      description = "Allow Postgres from RDS subnets"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = [for subnet in data.aws_subnet.rds : subnet.cidr_block]
    }
  }
}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.rds_instance_identifier}-rds"
  subnet_ids = var.networking.subnet_ids
}