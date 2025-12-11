# KKNUntidar Backend (Next.js + Prisma + Postgres)

This folder contains a lightweight Next.js API backend scaffold using TypeScript and Prisma with PostgreSQL.

Quick setup (Docker - recommended):

1. Copy `.env.example` to `.env` if you want to run outside docker and adjust `DATABASE_URL`.
2. Run with docker-compose (starts Postgres and the Next dev server):

```bash
cd backend
docker compose up --build
```

3. Initialize Prisma (inside container or locally):

```bash
# locally (requires node/npm installed)
npm install
npx prisma generate
npx prisma migrate dev --name init
```

API endpoints (examples):
- `GET /api/health` - health check
- `GET /api/users` - list users
- `POST /api/users` - create user { name, email }
- `GET /api/activities` - list activities
- `POST /api/activities` - create activity { title, description, userId }
- `GET /api/announcements` - list announcements

Preserving Git history
- If you later move files into this folder from elsewhere and want to preserve git history, run `git mv <oldpath> <newpath>` from your local checkout before committing. Example:

```bash
# from repo root
git mv flutter_app/lib/models backend/src/models
git commit -m "move models into backend (preserve history)"
```

Notes
- This scaffold is minimal and intended to get you started. I can add JWT auth, middleware, tests, CI, or convert to a pure Express/Fastify service on request.
