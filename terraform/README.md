# Terraform

AWS infrastructure for Authentication24, provisioned with Terraform.

## Architecture

```
Internet
    │
    ▼
Route 53 (DNS)
    │
    ▼
ACM (SSL Certificate)
    │
    ▼
ALB — Application Load Balancer (public subnets)
    │
    ├── /api/*          → ECS backend  (private subnets)
    ├── /oauth2/*       → ECS backend
    ├── /login/oauth2/* → ECS backend
    └── /*              → ECS frontend (private subnets)
                                │
                    ┌───────────┴───────────┐
                    ▼                       ▼
              RDS PostgreSQL          ElastiCache Redis
              (private subnet)        (private subnet)
```

## Resources

| File | What it creates |
|---|---|
| `vpc.tf` | VPC, public/private subnets, IGW, NAT Gateway |
| `security_groups.tf` | Firewall rules for ALB, ECS, RDS, Redis |
| `ecr.tf` | ECR repositories for backend and frontend images |
| `secrets.tf` | Secrets Manager — DB password, JWT secret, SMTP, OAuth2 credentials |
| `rds.tf` | RDS PostgreSQL instance |
| `elasticache.tf` | ElastiCache Redis cluster |
| `iam.tf` | ECS task execution role and task role |
| `alb.tf` | Application Load Balancer, target groups, listeners, routing rules |
| `acm.tf` | ACM SSL certificate with Route 53 DNS validation |
| `ecs.tf` | ECS Fargate cluster, task definitions, services |
| `outputs.tf` | ECR URLs, ALB DNS, RDS and Redis endpoints |

## Prerequisites

- AWS CLI configured with sufficient permissions
- S3 bucket `auth24-terraform-state` created in `ap-southeast-1` for remote state
- Route 53 hosted zone for your domain
- Domain nameservers pointed to Route 53

## Usage

**Phase 1 — provision infrastructure:**
```bash
terraform init
terraform apply
```

**Phase 2 — deploy after pushing Docker images:**
```bash
# Add to terraform.tfvars:
# backend_image  = "<ecr_backend_url>:latest"
# frontend_image = "<ecr_frontend_url>:latest"

terraform apply
```

## Variables

Copy and fill in `terraform.tfvars`:

```hcl
smtp_username = "your@gmail.com"
smtp_password = "your-app-password"

github_client_id     = "your-github-client-id"
github_client_secret = "your-github-client-secret"

google_client_id     = "your-google-client-id"
google_client_secret = "your-google-client-secret"

backend_image  = ""
frontend_image = ""
```
