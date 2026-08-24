import json
import os
import urllib.request
import boto3


def handler(event, context):
    client = boto3.client("secretsmanager", region_name=os.environ["AWS_REGION"])
    webhook_url = client.get_secret_value(SecretId=os.environ["SLACK_WEBHOOK_SECRET"])["SecretString"]

    for record in event["Records"]:
        subject = record["Sns"].get("Subject", "")
        raw_message = record["Sns"]["Message"]

        try:
            sns_message = json.loads(raw_message)
        except (json.JSONDecodeError, TypeError):
            sns_message = None

        if sns_message and "AlarmName" in sns_message:
            alarm_name = sns_message["AlarmName"]
            new_state = sns_message["NewStateValue"]
            reason = sns_message["NewStateReason"]
            emoji = ":red_circle:" if new_state == "ALARM" else ":large_green_circle:"
            text = f"{emoji} *{alarm_name}*\nState: `{new_state}`\n{reason}"
            payload = json.dumps({"text": text}).encode()
        elif sns_message and ("Event Source" in sns_message or "Event ID" in sns_message):
            source_id = sns_message.get("Source ID", "RDS")
            message = sns_message.get("Event Message", str(sns_message))
            event_id = sns_message.get("Event ID", "")
            text = f":warning: *RDS Event* ({source_id})\n{message}\n`{event_id}`"
            payload = json.dumps({"text": text}).encode()
        else:
            firing = subject.startswith("[FIRING]")
            payload = json.dumps({
                "attachments": [{
                    "color": "#ff0000" if firing else "#36a64f",
                    "title": subject,
                    "text": raw_message,
                    "footer": "AMP Alertmanager",
                }]
            }).encode()

        req = urllib.request.Request(
            webhook_url,
            data=payload,
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        urllib.request.urlopen(req)
