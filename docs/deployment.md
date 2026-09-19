# Deployment Guide — ACME Salary Management System

## Target Architecture

```
GitHub Repository
       │
       └─ Render Auto-Deploy
            ├─ Render Static Site  (React frontend)
            ├─ Render Web Service  (Rails API)
            └─ Render PostgreSQL   (Managed database)
```

---

## Prerequisites Before Deploying

Before attempting any deployment, confirm all of the following locally:

- [ ] `bundle exec rspec` — all tests pass
- [ ] `bundle exec rubocop` — no offenses
- [ ] `npm test` — all frontend tests pass
- [ ] `npm run lint` — no lint errors
- [ ] `npm run build` — production build succeeds (no TS errors)
- [ ] `bin/rails db:seed` — seeds 10,000 employees successfully
- [ ] `bin/rails server` — backend starts and health endpoint responds
- [ ] `npm run dev` — frontend starts and communicates with backend

---

## Environment Variables

### Rails Backend

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | Full PostgreSQL connection string | `postgresql://user:pass@host:5432/db` |
| `RAILS_ENV` | Must be `production` | `production` |
| `RAILS_MASTER_KEY` | Rails credentials master key | (from `config/master.key`, never committed) |
| `FRONTEND_URL` | Frontend origin for CORS | `https://salary-mgmt.onrender.com` |
| `RAILS_LOG_TO_STDOUT` | Enable stdout logging on Render | `true` |

### React Frontend

| Variable | Description | Example |
|----------|-------------|---------|
| `VITE_API_BASE_URL` | Backend API base URL | `https://salary-mgmt-api.onrender.com` |

---

## Deployment Steps

### Step 1: Create Render PostgreSQL Database

1. Log in to [Render Dashboard](https://dashboard.render.com)
2. Click **New** → **PostgreSQL**
3. Name: `salary-mgmt-db`
4. Region: Choose closest to your users
5. Click **Create Database**
6. Copy the **Internal Database URL** (for Rails) — do NOT commit this

### Step 2: Deploy Rails Backend

1. Click **New** → **Web Service**
2. Connect your GitHub repository
3. Name: `salary-mgmt-api`
4. Branch: `main`
5. Root Directory: `backend`
6. Environment: **Ruby**
7. Build Command: `bundle install && bundle exec rake assets:precompile 2>/dev/null; bundle exec rake db:migrate`
8. Start Command: `bundle exec rails server -b 0.0.0.0`
9. Add environment variables (from the table above)
10. Click **Create Web Service**

### Step 3: Run Database Migrations

Migrations run automatically as part of the Build Command above (`rake db:migrate`).

Verify: Check the deploy logs for "== [timestamp] CreateEmployees: migrated"

### Step 4: Seed Demonstration Data (First Time Only)

> ⚠️ **This step is manual and intentional.** The seed is NOT run automatically on deploy to prevent accidental data destruction on redeployment.

In the Render web service dashboard:
1. Click **Shell**
2. Run: `bin/rails db:seed`
3. Verify: `bin/rails runner "puts Employee.count"` → should print `10000`

### Step 5: Verify Backend Health

Open: `https://salary-mgmt-api.onrender.com/api/health`

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2026-09-19T08:00:00Z",
  "database": "connected",
  "employee_count": 10000
}
```

### Step 6: Deploy React Frontend

1. Click **New** → **Static Site**
2. Connect your GitHub repository
3. Name: `salary-mgmt`
4. Branch: `main`
5. Root Directory: `frontend`
6. Build Command: `npm ci && npm run build`
7. Publish Directory: `dist`
8. Add environment variable: `VITE_API_BASE_URL=https://salary-mgmt-api.onrender.com`
9. Click **Create Static Site**

### Step 7: Configure CORS on Backend

Set the `FRONTEND_URL` environment variable on the Rails web service to the URL of your deployed static site (e.g., `https://salary-mgmt.onrender.com`).

Redeploy the Rails service after setting this variable.

### Step 8: Verify Full Stack

- [ ] Open `https://salary-mgmt.onrender.com` — dashboard loads
- [ ] Employee list shows employees with pagination
- [ ] Search returns filtered results
- [ ] Employee detail shows salary and history
- [ ] Salary update form submits and updates correctly
- [ ] Analytics dashboard shows correct totals
- [ ] `GET /api/health` returns 200 with `"database": "connected"`

---

## Production Safety Rules

1. **Never commit** `config/master.key`, `DATABASE_URL`, or any secret to the repository
2. **Never run** `rails db:seed` on a production database unless you intend to populate it (it will create duplicates if records exist — the seed uses `find_or_create_by` for idempotency where possible)
3. **Never run** `rails db:reset` on production — this drops and recreates the database
4. **Migrations** run automatically on deploy and are safe to run multiple times (idempotent by Rails convention)
5. **Environment variables** are set in Render's dashboard, never in `.env` files committed to git

---

## Re-deployment

After code changes:

1. Push to `main` branch on GitHub
2. Render auto-deploys both services
3. Migrations run automatically as part of the build
4. No manual steps required for code updates (only for first-time seeding)

---

## Rollback

If a deployment causes issues:
1. In Render, click the failing web service
2. Click **Deploys**
3. Click the last successful deploy → **Redeploy**

If a migration caused the issue, roll back the migration locally first, create a new migration to undo it, and push.

---

## Monitoring

Render provides basic logs per service. For more detail:

- Rails logs: `RAILS_LOG_TO_STDOUT=true` (set as env variable) streams to Render log viewer
- Database: Render PostgreSQL dashboard shows connection count and storage

No external monitoring service is configured for this assessment.
