module "prometheus_confs" {
  source = "git::https://github.com/Ferlab-Ste-Justine/terraform-prometheus-configuration.git?ref=v0.3.1"
  terracd_jobs             = var.terracd_jobs
  node_exporter_jobs       = var.node_exporter_jobs
  blackbox_exporter_jobs   = var.blackbox_exporter_jobs
  kubernetes_exporter_jobs = var.kubernetes_exporter_jobs
  starrocks_exporter_jobs  = var.starrocks_exporter_jobs
  heartbeat                = var.heartbeat
}

resource "aws_prometheus_rule_group_namespace" "prometheus_confs" {
  for_each = { for rule in module.prometheus_confs.rules : rule.name => rule }

  workspace_id = var.workspace_id
  name = each.value.name
  data = each.value.content
}