resource "aws_security_group" "pipeline_task" {
  count       = length(var.scheduler.security_groups) == 0 ? 1 : 0 
  name        = "terracd-pipeline-task-${var.name}"
  description = "terracd pipeline - egress only"
  vpc_id      = var.vpc_id

  tags = var.tags
}

resource "aws_vpc_security_group_egress_rule" "pipeline_task_all" {
  count             = length(var.scheduler.security_groups) == 0 ? 1 : 0 
  security_group_id = aws_security_group.pipeline_task.0.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}