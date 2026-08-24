import json
import logging
import os
import urllib.request
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def process_alertmanager(subject, raw_message):
    if not subject.startswith("[FIRING]") and not subject.startswith("[RESOLVED]"):
        return None, False
    firing = subject.startswith("[FIRING]")
    payload = json.dumps({
        "attachments": [{
            "color": "#ff0000" if firing else "#36a64f",
            "title": subject,
            "text": raw_message,
            "footer": "AMP Alertmanager",
        }]
    }).encode()
    return payload, True


def process_cloudwatch(subject, raw_message):
    try:
        msg = json.loads(raw_message)
    except (json.JSONDecodeError, TypeError):
        return None, False
    if "AlarmName" not in msg:
        return None, False
    new_state = msg["NewStateValue"]
    emoji = ":red_circle:" if new_state == "ALARM" else ":large_green_circle:"
    text = f"{emoji} *{msg['AlarmName']}*\nState: `{new_state}`\n{msg['NewStateReason']}"
    return json.dumps({"text": text}).encode(), True


def process_rds(subject, raw_message):
    try:
        msg = json.loads(raw_message)
    except (json.JSONDecodeError, TypeError):
        return None, False
    if "Event Source" not in msg and "Event ID" not in msg:
        return None, False
    source_id = msg.get("Source ID", "RDS")
    message = msg.get("Event Message", str(msg))
    event_id = msg.get("Event ID", "")
    text = f":warning: *RDS Event* ({source_id})\n{message}\n`{event_id}`"
    return json.dumps({"text": text}).encode(), True


PROCESSOR_MAP = {
    "alertmanager": process_alertmanager,
    "cloudwatch":   process_cloudwatch,
    "rds":          process_rds,
}


def handler(event, context):
    client = boto3.client("secretsmanager", region_name=os.environ["AWS_REGION"])
    webhook_url = client.get_secret_value(SecretId=os.environ["SLACK_WEBHOOK_SECRET"])["SecretString"]

    sources = os.environ.get("NOTIFICATION_SOURCES", "alertmanager,cloudwatch,rds").split(",")
    processors = [PROCESSOR_MAP[s.strip()] for s in sources if s.strip() in PROCESSOR_MAP]

    for record in event["Records"]:
        subject = record["Sns"].get("Subject", "")
        raw_message = record["Sns"]["Message"]

        matched = False
        for processor in processors:
            payload, matched = processor(subject, raw_message)
            if matched:
                break

        if matched:
            req = urllib.request.Request(
                webhook_url,
                data=payload,
                headers={"Content-Type": "application/json"},
                method="POST",
            )
            urllib.request.urlopen(req)
        else:
            logger.warning("No processor matched for SNS record: subject=%s", subject)
