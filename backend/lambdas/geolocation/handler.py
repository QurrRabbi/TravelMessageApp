import json
from math import radians, sin, cos, sqrt, atan2

PROXIMITY_RADIUS_METRES = 50.0


def haversine_distance(lat1, lon1, lat2, lon2) -> float:
    """Calculate distance in metres between two coordinates using the Haversine formula."""
    R = 6_371_000  # Earth radius in metres
    phi1, phi2 = radians(lat1), radians(lat2)
    dphi = radians(lat2 - lat1)
    dlambda = radians(lon2 - lon1)
    a = sin(dphi / 2) ** 2 + cos(phi1) * cos(phi2) * sin(dlambda / 2) ** 2
    return R * 2 * atan2(sqrt(a), sqrt(1 - a))


def lambda_handler(event, context):
    """Validate whether a user is within 50m of a tagged message location."""
    body = json.loads(event.get("body", "{}"))
    user_lat = body.get("userLatitude")
    user_lon = body.get("userLongitude")
    msg_lat = body.get("messageLatitude")
    msg_lon = body.get("messageLongitude")

    if None in (user_lat, user_lon, msg_lat, msg_lon):
        return {"statusCode": 400, "body": json.dumps({"error": "Missing coordinates"})}

    distance = haversine_distance(user_lat, user_lon, msg_lat, msg_lon)
    within_proximity = distance <= PROXIMITY_RADIUS_METRES

    return {
        "statusCode": 200,
        "body": json.dumps({
            "withinProximity": within_proximity,
            "distanceMetres": round(distance, 2)
        })
    }
