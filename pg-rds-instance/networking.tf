locals {
  apply_existing_sg_ids  = try(var.networking.access_control.apply_existing_sg_ids, [])
  allowed_ingress_sg_ids = try(var.networking.access_control.allowed_ingress.sg_ids, [])
  allowed_ingress_subnet = try(var.networking.access_control.allowed_ingress.subnet, false)

  manage_sg = length(local.allowed_ingress_sg_ids) > 0 || local.allowed_ingress_subnet

  rds_security_group_ids = concat(
    local.apply_existing_sg_ids,
    local.manage_sg ? [aws_security_group.rds[0].id] : []
  )
}

data "aws_subnet" "rds" {
  for_each = local.allowed_ingress_subnet ? toset(var.networking.subnet_ids) : toset([])
  id       = each.value
}

resource "aws_security_group" "rds" {
  count = local.manage_sg ? 1 : 0

  name        = "${var.rds_instance_identifier}-rds"
  description = "Security group for ${var.rds_instance_identifier} RDS instance"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "rds" {
  count = local.manage_sg ? 1 : 0

  security_group_id = aws_security_group.rds[0].id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_security_group" {
  for_each = toset(local.allowed_ingress_sg_ids)

  security_group_id            = aws_security_group.rds[0].id
  description                  = "Postgres from ${each.value}"
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = each.value
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_subnet" {
  for_each = data.aws_subnet.rds

  security_group_id = aws_security_group.rds[0].id
  description       = "Postgres from subnet ${each.value.id}"
  ip_protocol       = "tcp"
  from_port         = 5432
  to_port           = 5432
  cidr_ipv4         = each.value.cidr_block
}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.rds_instance_identifier}-rds"
  subnet_ids = var.networking.subnet_ids
}
