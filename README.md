# Authentication24

A full-stack authentication system built with Next.js and Spring Boot, deployed on AWS with Terraform.

## Features

- Email/password registration with email verification
- Password reset via email code
- GitHub and Google OAuth2 login
- JWT access + refresh tokens (stored in HttpOnly cookies)
- User profile — edit name, change password, delete account
- Admin panel — view users, change roles, delete accounts

## Architecture

```
Browser
  │
  ▼
Route 53 (DNS) → ACM (TLS)
  │
  ▼
ALB — Application Load Balancer (public subnets)
  │
  ├── /api/*           → ECS backend  (Spring Boot, port 8080)
  ├── /oauth2/*        → ECS backend
  ├── /login/oauth2/*  → ECS backend
  └── /*               → ECS frontend (Next.js, port 3000)
                               │
                   ┌───────────┴───────────┐
                   ▼                       ▼
             RDS PostgreSQL          ElastiCache Redis
             (private subnet)        (private subnet)
```

All ECS tasks run in private subnets — only the ALB is publicly accessible.
Secrets (DB password, JWT secret, SMTP and OAuth2 credentials) are stored in AWS Secrets Manager and injected at container startup.

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Next.js 15, TypeScript, Tailwind CSS |
| Backend | Spring Boot 3.5, Spring Security, Spring Data JPA |
| Database | PostgreSQL 16 (RDS) |
| Cache / Sessions | Redis 7 (ElastiCache) |
| Auth | JWT, Spring OAuth2 Client (GitHub, Google) |
| Infrastructure | AWS ECS Fargate, ALB, RDS, ElastiCache, ECR, Secrets Manager, ACM, Route 53 |
| IaC | Terraform |
| CI/CD | GitHub Actions |

## Repository Structure

```
.
├── backend/          Spring Boot API
├── frontend/         Next.js app
├── nginx-proxy/      Reverse proxy for local development
├── terraform/        AWS infrastructure (Terraform)
└── docker-compose.yml
```

## API Endpoints

| Method | Path | Description |
|---|---|---|
| POST | `/api/auth/register` | Register with email + password |
| POST | `/api/auth/verify` | Verify email with code |
| POST | `/api/auth/login` | Login, receive JWT cookies |
| POST | `/api/auth/refresh` | Refresh access token |
| POST | `/api/auth/logout` | Clear JWT cookies |
| POST | `/api/auth/forgot-password` | Send password reset code |
| POST | `/api/auth/reset-password` | Reset password with code |
| GET | `/api/users/me` | Get current user profile |
| PATCH | `/api/users/me/name` | Update display name |
| PATCH | `/api/users/me/password` | Change password |
| DELETE | `/api/users/me` | Delete own account |
| GET | `/api/admin/users` | List all users (admin only) |
| PATCH | `/api/admin/users/{id}/role` | Change user role (admin only) |
| PATCH | `/api/admin/users/{id}/name` | Edit user name (admin only) |
| DELETE | `/api/admin/users/{id}` | Delete user (admin only) |

OAuth2 flows are handled automatically by Spring Security at `/oauth2/authorization/{provider}`.

## Local Development

**Prerequisites:** Docker, Docker Compose

```bash
# Copy and fill in the backend config
cp backend/src/main/resources/application.example.yml \
   backend/src/main/resources/application.yml

# Start all services (frontend, backend, postgres, redis, nginx)
docker-compose up
```

The app runs at `http://localhost`.

For OAuth2 to work locally, register `http://localhost/login/oauth2/code/github` and `http://localhost/login/oauth2/code/google` as callback URLs in your GitHub and Google OAuth apps.

## Deployment

Infrastructure is provisioned with Terraform. See [`terraform/README.md`](terraform/README.md) for full instructions.

CI/CD is handled by GitHub Actions — pushing to `main` automatically builds and deploys changed services to ECS.

**OAuth2 callback URLs to register for production:**

| Provider | Callback URL |
|---|---|
| GitHub | `https://<your-domain>/login/oauth2/code/github` |
| Google | `https://<your-domain>/login/oauth2/code/google` |
