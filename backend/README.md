# TravelMessageApp Backend

AWS Lambda backend deployed in **eu-west-2 (London)**.

## Lambdas

| Lambda | Path | Purpose |
|--------|------|---------|
| auth | `/auth` | Gmail OAuth token exchange |
| messages | `/messages` | Geo-locked message CRUD |
| journeys | `/journeys` | Journey and route management |
| geolocation | `/geolocation/validate` | 50m proximity validation |

## Infrastructure

- **AWS SAM** (`template.yaml`) for Lambda + API Gateway provisioning
- **S3 bucket** (`travelmessageapp-media-eu-west-2`) for photo/media storage with KMS encryption

## Deploy

```bash
sam build
sam deploy --guided --region eu-west-2
```
