# Backend

Spring Boot 3 backend for Authentication24 — a full-stack authentication platform.

## Tech Stack

- **Framework** — Spring Boot 3.5
- **Language** — Java 21
- **Database** — PostgreSQL (JPA/Hibernate)
- **Cache** — Redis
- **Auth** — JWT (access + refresh tokens via httpOnly cookies)
- **OAuth2** — GitHub, Google (OIDC)
- **Email** — SMTP via Spring Mail

## Features

- Email/password registration with Redis-backed verification codes
- JWT authentication with access and refresh token rotation
- OAuth2 login via GitHub and Google
- Forgot password / reset password via email code
- User profile management — update name, change password, delete account
- Admin endpoints — list users (paginated), update name and role
- Global exception handler returning structured JSON error responses

## Local Development

Copy the example config and fill in your values:

```bash
cp src/main/resources/application.example.yml src/main/resources/application.yml
```

Then run:

```bash
./mvnw spring-boot:run
```

Runs on `http://localhost:8080`. Requires PostgreSQL on port 5432 and Redis on port 6379.

Use Docker Compose from the project root to start all dependencies:

```bash
docker-compose up
```

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `SPRING_DATASOURCE_URL` | PostgreSQL JDBC URL | `jdbc:postgresql://localhost:5432/appdb` |
| `SPRING_DATASOURCE_USERNAME` | Database username | `postgres` |
| `SPRING_DATASOURCE_PASSWORD` | Database password | `postgres` |
| `REDIS_HOST` | Redis host | `localhost` |
| `REDIS_PORT` | Redis port | `6379` |
| `JWT_SECRET` | Secret key for signing JWTs | dev default |
| `SMTP_HOST` | SMTP server host | `smtp.gmail.com` |
| `SMTP_PORT` | SMTP server port | `587` |
| `SMTP_USERNAME` | SMTP login / sender address | — |
| `SMTP_PASSWORD` | SMTP password or app password | — |
| `GITHUB_CLIENT_ID` | GitHub OAuth2 client ID | — |
| `GITHUB_CLIENT_SECRET` | GitHub OAuth2 client secret | — |
| `GOOGLE_CLIENT_ID` | Google OAuth2 client ID | — |
| `GOOGLE_CLIENT_SECRET` | Google OAuth2 client secret | — |
| `OAUTH2_REDIRECT_URI` | Post-login redirect URL | `http://localhost` |
