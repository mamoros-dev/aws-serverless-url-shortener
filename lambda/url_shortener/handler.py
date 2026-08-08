import json
import os
import random
import string
import time
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])

ALPHABET = string.ascii_letters + string.digits


def generate_short_code(length=6):
    return "".join(random.choices(ALPHABET, k=length))


def create_short_url(event):
    body = json.loads(event.get("body") or "{}")
    long_url = body.get("long_url")

    if not long_url:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "long_url is required"}),
        }

    short_code = generate_short_code()

    table.put_item(
        Item={
            "short_code": short_code,
            "long_url": long_url,
            "created_at": int(time.time()),
            "click_count": 0,
        }
    )

    return {
        "statusCode": 201,
        "body": json.dumps({"short_code": short_code}),
    }


def redirect(event):
    short_code = event["pathParameters"]["short_code"]

    try:
        response = table.update_item(
            Key={"short_code": short_code},
            UpdateExpression="ADD click_count :inc",
            ExpressionAttributeValues={":inc": 1},
            ConditionExpression="attribute_exists(short_code)",
            ReturnValues="ALL_NEW",
        )
    except dynamodb.meta.client.exceptions.ConditionalCheckFailedException:
        return {
            "statusCode": 404,
            "body": json.dumps({"error": "short_code not found"}),
        }

    long_url = response["Attributes"]["long_url"]

    return {
        "statusCode": 301,
        "headers": {"Location": long_url},
        "body": "",
    }


def lambda_handler(event, context):
    method = event.get("httpMethod")
    path = event.get("path", "")

    if method == "POST" and path == "/links":
        return create_short_url(event)

    if method == "GET" and event.get("pathParameters", {}).get("short_code"):
        return redirect(event)

    return {
        "statusCode": 404,
        "body": json.dumps({"error": "route not found"}),
    }
