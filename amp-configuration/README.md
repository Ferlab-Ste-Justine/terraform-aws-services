# amp-configuration

A thin AWS wrapper around [`terraform-prometheus-configuration`](https://github.com/Ferlab-Ste-Justine/terraform-prometheus-configuration/tree/v0.3.0).

This module takes a set of high-level monitoring job definitions, uses the upstream Ferlab module to render them into Prometheus alerting rules, and deploys those rules to an **Amazon Managed Service for Prometheus (AMP)** workspace as rule group namespaces.

## What it does

1. Passes your job definitions (`terracd`, `node_exporter`, `blackbox_exporter`, `kubernetes_exporter`) to the upstream `terraform-prometheus-configuration` module, which produces a map of Prometheus rule groups.
2. Creates one `aws_prometheus_rule_group_namespace` resource per rendered rule group, attached to the AMP workspace you specify.

The rule-authoring logic lives entirely in the upstream module; this wrapper only handles delivery to AMP.


## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `workspace_id` | `string` | yes | ID of the AMP workspace the rule group namespaces are attached to. |
| `terracd_jobs` | `list(object)` | no (defaults to `[]`) | terraCD job definitions. |
| `node_exporter_jobs` | `list(object)` | no (defaults to `[]`) | node-exporter job definitions. |
| `blackbox_exporter_jobs` | `list(object)` | no (defaults to `[]`) | blackbox-exporter job definitions. |
| `kubernetes_exporter_jobs` | `list(object)` | no (defaults to `[]`) | kubernetes-exporter job definitions. |

The job list objects mirror the upstream module's schema one-to-one. Rather than duplicate every field here, refer to the upstream documentation for the meaning of each attribute and its expected values:

**https://github.com/Ferlab-Ste-Justine/terraform-prometheus-configuration/tree/v0.3.0**

The exact object shapes are defined in [`variables.tf`](./variables.tf).

## Resources created

- `aws_prometheus_rule_group_namespace` — one per rule group returned by the upstream module (created with `for_each`, keyed by rule group name).

## Requirements

- The `aws` provider, configured with permissions to manage `aws_prometheus_rule_group_namespace` resources in the target workspace.
- Git access to `github.com` at plan/init time, since the upstream module is sourced via a pinned git ref (`v0.3.0`).