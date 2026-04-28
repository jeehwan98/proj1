# Frontend

Next.js 16 frontend for Authentication24 — a full-stack authentication platform.

## Tech Stack

- **Framework** — Next.js 16 (App Router)
- **Language** — TypeScript
- **Styling** — Tailwind CSS
- **Icons** — Lucide React

## Features

- Email/password registration with verification code
- Login with GitHub and Google OAuth2
- Forgot password / reset password flow
- Profile page — edit display name, change password, delete account
- Admin panel — view all users, edit name and role
- Dark/light theme toggle
- JWT auth with httpOnly cookies and automatic token refresh

## Local Development

```bash
npm install
npm run dev
```

Runs on `http://localhost:3000`. Expects the backend at `http://localhost:8080`.

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `NEXT_PUBLIC_API_URL` | Backend API base URL | `http://localhost:8080/api` |
