# AWS Serverless URL Shortener

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Dependabot](https://img.shields.io/badge/Dependabot-active-0288d1?logo=dependabot)](./.github/dependabot.yml)

🇪🇸 [Spanish version and more info](./docs/es/README-es.md)  

+ Serverless URL shortener API (Lambda + API Gateway + DynamoDB), fully deployed with Terraform. When someone creates a short link, the system stores it; when someone visits it, it redirects to the original URL and counts the click. Project 3 of an AWS/Terraform portfolio series.


## Table of contents

- [Architecture Decisions](#architecture-decisions)
- [Infrastructure Verification](#infrastructure-verification)
- [How to install and run the project](#how-to-install-and-run-the-project)
- [How to use the project](#how-to-use-the-project)`
- [Stack](#stack)
- [Status](#status)
- [Author](#author)

## Architecture Decisions

+ Decisions:
  * **Fully Serverless & Pay-as-You-Go:** Leverages AWS Lambda and API Gateway to eliminate compute idle costs and scale automatically from zero to high demand.
  * **Low-Latency NoSQL Storage:** Uses Amazon DynamoDB with single-table design to achieve millisecond response times for URL key lookups and analytics tracking.
  * **Decoupled API Tier:** Amazon API Gateway manages HTTP endpoints, request validation, CORS, and rate limiting directly at the edge before triggering Lambda execution.
  * **Least-Privilege IAM Roles:** Lambda execution roles are granted fine-grained IAM permissions, restricted strictly to DynamoDB `GetItem` and `PutItem` operations on the specific table ARN.

![Arquitectura](docs/images/diagrama.png)
> Client → API Gateway (HTTP API) → Lambda (Python) → DynamoDB, with an IAM role with minimal permissions between Lambda and DynamoDB, and CloudWatch Logs recording both API access and function execution.

**Request Flow:**
1. The client sends an HTTP request to the API’s public URL.
2. API Gateway receives the request and forwards it to the Lambda function via an `AWS_PROXY` integration.
3. The Lambda function, running under a scoped IAM role, processes the request:
   - `POST /links` → generates a short code and stores it in DynamoDB.
   - `GET /{short_code}` → looks up the code, incrementally updates the click counter atomically, and returns a `301` redirect to the original URL.
4. DynamoDB stores and returns the data.
5. CloudWatch Logs records each request and any execution errors.


## Infrastructure Verification

![Consola Lambda](docs/images/lambda-console.png)
![Consola Lambda](docs/images/lambda-permissions.png)
*Lambda function with the IAM role assigned and Python 3.12 runtime.*

![Environment Variables](docs/images/lambda-env-vars.png)
*The `TABLE_NAME` environment variable is injected from Terraform, rather than being hardcoded in the code.*

![Routes API Gateway](docs/images/api-gateway-routes.png)
*The two routes (`POST /links`, `GET /{short_code}`) point to the same integration.*

![DynamoDB Items](docs/images/dynamo-items.png)
*A real item created during testing, with `click_count` incremented.*


```bash
# Create a short URL / Crear una URL corta [$API_URL == api_endpoint]
curl -i -X POST "$API_URL/links" \
  -H "Content-Type: application/json" \
  -d '{"long_url": "https://www.linkedin.com/in/miguel-amoros-moret"}'
# → HTTP/2 201, body: {"short_code": "w9u8wX"}

# Visit the short URL / Visitar la URL corta
curl -i "$API_URL/w9u8wX"
# → HTTP/2 301, location: https://www.linkedin.com/in/miguel-amoros-moret
```
![Test curl](docs/images/curl.png)

```bash
# Test with a unknow code / Probar un código inexistente
curl -i "$API_URL/notexist"
# → HTTP/2 404, {"error": "short_code not found"}
```
![Test curl](docs/images/curl2.png)

```bash
# Check click's count / Verificar el contador de clics tras varias visitas
aws dynamodb get-item \
  --table-name url-shortener-dev-links \
  --key '{"short_code": {"S": "w9u8wX"}}' \
  --profile personal
# → click_count incrementado correctamente, sin pérdidas bajo visitas repetidas
```
![Test curl](docs/images/curl3.png)


## How to install and run the project

+ Clone the repository:
```bash
git clone git@github.com:mamoros-dev/aws-serverless-url-shortener.git
cd aws-serverless-url-shortener

cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values if they differ from the example

terraform init
terraform plan
terraform apply
```

+ Get the API's public URL:
```bash
terraform output api_endpoint
```

+ To tear down the infrastructure:
```bash
terraform destroy
```

## How to use the project

| Method | Route | Description |
|---|---|---|
| `POST` | `/links` | Creates a short URL. Body: `{"long_url": "https://..."}` |
| `GET` | `/{short_code}` | Redirects (301) to the associated long URL and increments the click counter |

+ Create and visit a short URL:
```bash
# Create a short URL
curl -i -X POST "$API_URL/links" \
  -H "Content-Type: application/json" \
  -d '{"long_url": "https://www.linkedin.com/in/your-profile"}'

# Visit the short URL (follow the redirect with -L)
curl -iL "$API_URL/<short_code>"
```

## Stack

+ AWS Lambda (Python 3.12) · API Gateway (HTTP API) · DynamoDB · IAM · CloudWatch Logs · Terraform

## Status
+ ✅ Complete project — design, infrastructure, code, integration, end-to-end testing, and documentation.

+ Infrastructure is destroyed after the final documentation (`terraform destroy`) to avoid unnecessary costs. It can be recreated in minutes with `terraform apply` by following the deployment steps.

## Author

+ Miguel — [GitHub](https://github.com/mamoros-dev) · [LinkedIn](https://www.linkedin.com/in/miguel-amoros-moret/)