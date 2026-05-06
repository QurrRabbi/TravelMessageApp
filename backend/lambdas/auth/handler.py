import json


def lambda_handler(event, context):
    """Gmail OAuth callback and token exchange."""
    # TODO: Implement Gmail OAuth flow
    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Auth handler placeholder"})
    }
