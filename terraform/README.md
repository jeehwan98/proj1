# Workplace Terraform

AWS infrastructure for the Workplace application — Next.js frontend, Spring Boot backend, and Lambda email sender, orchestrated with ECS Fargate.

## Architecture

```
Internet (HTTPS)
    ↓
ALB (public subnets)
    ↓
ECS Fargate Task (private subnets)
  ├── frontend  (Next.js, port 3000)
  └── backend   (Spring Boot, port 8080)
        ↓
    RDS PostgreSQL (private subnets)
        ↓
    SQS invoice-email queue
        ↓
    Lambda email-sender
        └── Gmail SMTP
```

## Files

| File | What it provisions |
|------|--------------------|
| `main.tf` | Terraform backend (S3), AWS provider |
| `locals.tf` | Shared name prefix, tags, AZs, OIDC config |
| `variables.tf` | All input variables |
| `ecr.tf` | ECR repos for backend, frontend, lambda |
| `ecs.tf` | ECS cluster, task definition, service |
| `iam.tf` | ECS execution role, task role, permissions |
| `sqs.tf` | Invoice email queue + dead letter queue |
| `lambda.tf` | Lambda function, IAM role, SQS trigger |

## Requirements

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- AWS CLI configured (`aws configure`)
- An S3 bucket named `jee-terraform-state` for remote state

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `aws_region` | `ap-southeast-1` | No | AWS region |
| `app_name` | `jee` | No | Used to name all resources |
| `environment` | `prod` | No | Deployment environment |
| `domain_name` | — | Yes | Your domain (e.g. `example.com`) |
| `google_client_id` | — | Yes | Google OAuth 2.0 Client ID |
| `google_client_secret` | — | Yes | Google OAuth 2.0 Client Secret |
| `db_instance_class` | `db.t3.micro` | No | RDS instance size |
| `smtp_user` | — | Yes | Gmail account for sending emails |
| `smtp_password` | — | Yes | Gmail app password |
| `google_service_account_json` | — | Yes | Google service account JSON (for Sheets API) |
| `app_cpu` | `1024` | No | ECS task CPU units |
| `app_memory` | `2048` | No | ECS task memory (MB) |
| `backend_image` | `""` | No | Custom ECR image URI for backend |
| `frontend_image` | `""` | No | Custom ECR image URI for frontend |
| `lambda_email_sender_image` | `""` | No | Custom ECR image URI for Lambda |

## Usage

**1. Initialize**
```bash
terraform init
```

**2. Create a `terraform.tfvars` file for sensitive values**
```hcl
domain_name                 = "example.com"
google_client_id            = "your-client-id"
google_client_secret        = "your-client-secret"
smtp_user                   = "you@gmail.com"
smtp_password               = "your-app-password"
google_service_account_json = "{...}"
```

**3. Preview changes**
```bash
terraform plan
```

**4. Deploy**
```bash
terraform apply
```

**5. Destroy**
```bash
terraform destroy
```

## How Resources Connect

- **ECR** stores Docker images for backend, frontend, and Lambda
- **ECS** pulls images from ECR and runs them as containers in private subnets
- **IAM roles** give ECS permission to read secrets from Secrets Manager and send messages to SQS
- **SQS** receives invoice IDs from the backend and triggers the Lambda function
- **Lambda** consumes the SQS queue, fetches invoice data from RDS, and sends emails via Gmail SMTP
- **Dead Letter Queue (DLQ)** stores messages that failed 3 times for inspection

## Resource Naming

All resources are named using this pattern:

```
{app_name}-{environment}-{resource}
# e.g. jee-prod-backend, jee-prod-cluster
```

These are defined in `locals.tf`:
```hcl
name_prefix = "${var.app_name}-${var.environment}"
```
