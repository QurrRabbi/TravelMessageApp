import json
import os
import secrets
import urllib.request
import urllib.error

GOOGLE_TOKEN_INFO_URL = "https://oauth2.googleapis.com/tokeninfo"
GOOGLE_CLIENT_ID = os.environ.get("GOOGLE_CLIENT_ID", "")


def verify_google_id_token(id_token: str) -> dict:
    """Verify a Google ID token and return the decoded claims."""
    url = f"{GOOGLE_TOKEN_INFO_URL}?id_token={id_token}"
    try:
        with urllib.request.urlopen(url, timeout=5) as response:
            claims = json.loads(response.read().decode())
    except urllib.error.HTTPError as e:
        raise ValueError(f"Invalid ID token: {e.reason}")

    if claims.get("aud") != GOOGLE_CLIENT_ID:
        raise ValueError("Token audience does not match expected client ID.")

    return claims


def generate_session_token() -> str:
    """Generate a cryptographically secure session token."""
    return secrets.token_urlsafe(64)


def lambda_handler(event, context):
    """
    POST /auth/signin
    Body: { "idToken": "<Google ID token>" }
    Returns: { "token": "<session token>", "userId": "...", "email": "..." }
    """
    try:
        body = json.loads(event.get("body") or "{}")
        id_token = body.get("idToken")

        if not id_token:
            return _response(400, {"error": "Missing idToken in request body."})

        claims = verify_google_id_token(id_token)

        user_id = claims.get("sub")
        email = claims.get("email")

        if not user_id or not email:
            return _response(400, {"error": "Invalid token claims."})

        session_token = generate_session_token()

        # TODO: Persist session token and user record to DynamoDB
        # store_session(user_id, session_token)

        return _response(200, {
            "token": session_token,
            "userId": user_id,
            "email": email
        })

    except ValueError as e:
        return _response(401, {"error": str(e)})
    except Exception as e:
        return _response(500, {"error": "Internal server error."})


def _response(status_code: int, body: dict) -> dict:
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body)
    }
