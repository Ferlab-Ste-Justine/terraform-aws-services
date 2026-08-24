import json
import os
import urllib.request
import boto3


def handler(event, context):
    client = boto3.client("secretsmanager", region_name=os.environ["AWS_REGION"])
    webhook_url = client.get_secret_value(SecretId=os.environ["SLACK_WEBHOOK_SECRET"])["SecretString"]

    for record in event["Records"]:
        subject = record["Sns"].get("Subject", "")
        message = record["Sns"]["Message"]
        firing = subject.startswith("[FIRING]")

        payload = json.dumps({
            "attachments": [{
                "color": "#ff0000" if firing else "#36a64f",
                "title": subject,
                "text": message,
                "footer": "SNS",
            }]
        }).encode()

        req = urllib.request.Request(
            webhook_url,
            data=payload,
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        urllib.request.urlopen(req)
