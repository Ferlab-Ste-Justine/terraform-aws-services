template_files:
  alert_message.tmpl: |
    {{ define "alert_message" }}
    {{- range $idx, $alert := .Alerts }}
    {{- if $idx }}{{ printf "\n" }}{{ end }}
    {{- if eq $alert.Annotations.testing "true" }}*This alert is getting triggered deliberately for test purposes. Kindly ignore it*{{ printf "\n" }}{{ end }}
    {{- $alert.Annotations.description }}
    {{- end }}
    {{- end }}

alertmanager_config: |
  ${indent(2, alertmanager_config)}