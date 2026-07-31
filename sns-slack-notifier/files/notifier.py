import json
import os
import urllib.request
import boto3


def handler(event, context):
    client = boto3.client("secretsmanager", region_name=os.environ["AWS_REGION"])
    webhook_url = client.get_secret_value(SecretId=os.environ["SLACK_WEBHOOK_SECRET"])["SecretString"]

    for record in event["Records"]:
        sns_message = json.loads(record["Sns"]["Message"])

        if "AlarmName" in sns_message:
            alarm_name = sns_message["AlarmName"]
            new_state = sns_message["NewStateValue"]
            reason = sns_message["NewStateReason"]
            emoji = ":red_circle:" if new_state == "ALARM" else ":large_green_circle:"
            text = f"{emoji} *{alarm_name}*\nState: `{new_state}`\n{reason}"
        elif "Event Source" in sns_message or "Event ID" in sns_message:
            source_id = sns_message.get("Source ID", "RDS")
            message = sns_message.get("Event Message", str(sns_message))
            event_id = sns_message.get("Event ID", "")
            text = f":warning: *RDS Event* ({source_id})\n{message}\n`{event_id}`"
        else:
            body = json.dumps(sns_message, indent=2)[:1000]
            text = f":aws: *AWS Health Event*\n```{body}```"

        payload = json.dumps({"text": text}).encode()
        req = urllib.request.Request(
            webhook_url,
            data=payload,
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        urllib.request.urlopen(req)
