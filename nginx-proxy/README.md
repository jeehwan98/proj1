# nginx-proxy

Reverse proxy for local development via Docker Compose. Routes incoming requests to the correct container based on path.

## Routing Rules

| Path | Target |
|---|---|
| `/api/*` | backend (port 8080) |
| `/oauth2/*` | backend (port 8080) |
| `/login/oauth2/*` | backend (port 8080) |
| `/*` | frontend (port 3000) |

## Usage

Started automatically as part of Docker Compose — no manual setup needed.

```bash
docker-compose up
```

Listens on `http://localhost:80`.

## Note

This proxy is for local development only. In production, the AWS Application Load Balancer handles routing using the same path rules.
