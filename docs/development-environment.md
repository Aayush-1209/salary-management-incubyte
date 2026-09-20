# Development Environment

## Overview

This document records the actual development environment used for the Incubyte salary management assessment. All version values were read directly from the environment — none were invented.

---

## Operating System

- **Host OS:** Windows 11 (developer workstation)
- **Linux environment:** WSL2 — Ubuntu 24.04 LTS (installed for this project)
- **All backend development** (Ruby, Rails, PostgreSQL) runs inside WSL2 Ubuntu

---

## Runtime Versions

| Tool | Version | Notes |
|------|---------|-------|
| Ruby | 3.3.5 | Installed via rbenv in WSL2 Ubuntu 24.04 |
| Rails | 7.2.3.2 | Installed as gem |
| Node.js | 22.23.2 | Installed via nvm in WSL2 |
| PostgreSQL | 16.15 | Ubuntu package (Ubuntu 16.15-0ubuntu0.24.04.1) |
| Git | 2.43.0 | System git in WSL2 |
| OS (WSL2) | Ubuntu 24.04.5 LTS | Codename: noble |


---

## Package Manager

- **Ruby gems:** Bundler (standard gem bundler)
- **JavaScript:** npm (no pnpm or yarn installed)

---

## Repository

- **GitHub remote:** https://github.com/Aayush-1209/salary-management-incubyte.git
- **Branch:** main
- **Initial state:** Empty repository (single initial commit with README)

---

## Project Structure

```
salary-management-incubyte/
├── backend/          # Rails API application
├── frontend/         # React + TypeScript (Vite) application
├── docs/             # Documentation (requirements, architecture, etc.)
├── .github/
│   └── workflows/
│       └── ci.yml    # GitHub Actions CI
└── README.md
```

---

## Major Development Commands

### Backend (run from inside WSL2 in `backend/`)

```bash
# Start development server
bin/rails server

# Run database migrations
bin/rails db:migrate

# Seed the database (10,000 synthetic employees)
bin/rails db:seed

# Reset database (drop + create + migrate + seed)
bin/rails db:reset

# Run tests
bundle exec rspec

# Run linter
bundle exec rubocop

# Open Rails console
bin/rails console

# Check routes
bin/rails routes
```

### Frontend (run from `frontend/`)

```bash
# Install dependencies
npm install

# Start development server (Vite)
npm run dev

# Run tests
npm test

# Run tests in watch mode
npm run test:watch

# Lint
npm run lint

# Format
npm run format

# Build for production
npm run build
```

### Database Management

```bash
# Create databases
bin/rails db:create

# Run all pending migrations
bin/rails db:migrate

# Roll back last migration
bin/rails db:rollback

# Check migration status
bin/rails db:migrate:status

# Seed 10,000 employees
bin/rails db:seed

# Full reset (caution: destroys all data)
bin/rails db:reset
```

---

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `DATABASE_URL` | PostgreSQL connection string | Production |
| `RAILS_ENV` | Rails environment (`development`, `test`, `production`) | All |
| `RAILS_MASTER_KEY` | Rails credentials master key | Production |
| `FRONTEND_URL` | Frontend origin for CORS | Production |

---

## Local PostgreSQL Setup (WSL2)

```bash
# Start PostgreSQL service
sudo service postgresql start

# Create development user
sudo -u postgres createuser --createdb salary_mgmt_dev

# Databases are created by Rails
bin/rails db:create
```

---

## Notes

- All backend code should be run in WSL2 (not Windows PowerShell) due to gem native extension requirements
- The frontend can be developed and run on either Windows or WSL2; Windows is fine since Node.js is installed natively
- Git operations can be performed from either environment — the project folder is accessible from both
