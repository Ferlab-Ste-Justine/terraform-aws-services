route:
  group_by: ['alertname']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 1h
  receiver: default

receivers:
  - name: default
    sns_configs:
      - topic_arn: ${sns_topic_arn}
        sigv4:
          region: ${region}
        subject: '{{ .CommonAnnotations.summary }}'
        message: '{{ template "alert_message" . }}'