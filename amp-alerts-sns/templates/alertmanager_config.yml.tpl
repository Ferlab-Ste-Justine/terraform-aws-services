route:
  group_by: ['alertname']
  group_wait: 0s
  group_interval: 5m
  repeat_interval: 1h
  receiver: default

receivers:
  - name: default
    sns_configs:
      - topic_arn: ${sns_topic_arn}
        sigv4:
          region: ${region}
        send_resolved: true
        subject: '[{{ .Status | toUpper }}] {{ .CommonAnnotations.summary }}'
        message: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'