module "prometheus_confs" {
  source = "git::https://github.com/Ferlab-Ste-Justine/terraform-prometheus-configuration.git?ref=v0.1.0"
  terracd_jobs             = var.terracd_jobs
  node_exporter_jobs       = var.node_exporter_jobs
  blackbox_exporter_jobs   = var.blackbox_exporter_jobs
  kubernetes_exporter_jobs = var.kubernetes_exporter_jobs
}

resource "aws_prometheus_rule_group_namespace" "prometheus_confs" {
  for_each = module.prometheus_confs.rules

  workspace_id = var.workspace_id
  name = each.value.name
  data = each.value.content
}