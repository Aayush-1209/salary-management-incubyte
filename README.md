# Salary Management System — Incubyte Assessment

A web-based salary management system for ACME organization (~10,000 employees).

Built as a take-home assessment for the **Software Craftsperson / ROR-I** role at Incubyte.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | React 18 + TypeScript + Vite |
| Backend | Ruby on Rails 7.1 (API mode) |
| Database | PostgreSQL 16 |
| Testing (BE) | RSpec + FactoryBot |
| Testing (FE) | Vitest + React Testing Library |
| CI | GitHub Actions |
| Deployment | Render |

## Project Structure

```
salary-management-incubyte/
├── backend/           # Rails API application
├── frontend/          # React + TypeScript SPA
├── docs/              # Requirements, architecture, decisions
│   ├── requirements.md
│   ├── architecture.md
│   ├── data-model.md
│   ├── decisions.md
│   ├── testing-strategy.md
│   ├── trade-offs.md
│   ├── performance.md
│   ├── deployment.md
│   └── final-checklist.md
└── .github/
    └── workflows/
        └── ci.yml
```

## Local Development Setup

### Prerequisites

- WSL2 with Ubuntu 24.04 (for backend)
- Ruby 3.3+ (via rbenv in WSL2)
- Rails 7.1+
- PostgreSQL 16 (in WSL2)
- Node.js 22+ (Windows or WSL2)
- npm 10+

### Backend Setup (in WSL2)

```bash
cd backend
bundle install
bin/rails db:create db:migrate
bin/rails db:seed       # Seeds 10,000 synthetic employees
bin/rails server        # Starts on http://localhost:3000
```

### Frontend Setup

```bash
cd frontend
npm install
npm run dev             # Starts on http://localhost:5173
```

### Running Tests

```bash
# Backend
cd backend
bundle exec rspec       # All specs
bundle exec rubocop     # Lint

# Frontend
cd frontend
npm test                # All tests
npm run lint            # Lint
```

## Key Features

- **Employee directory** — search, filter by country/department, sort, paginate
- **Employee detail** — personal info, current salary, salary history
- **Salary management** — update salary with effective date and reason; history preserved
- **Analytics dashboard** — headcount, payroll totals, averages, country/department breakdowns

## Documentation

See the `docs/` folder for:

- [Requirements](docs/requirements.md)
- [Architecture](docs/architecture.md)
- [Data Model](docs/data-model.md)
- [Design Decisions](docs/decisions.md)
- [Testing Strategy](docs/testing-strategy.md)
- [Trade-offs](docs/trade-offs.md)
- [Performance](docs/performance.md)
- [Deployment Guide](docs/deployment.md)

## Live Demo & Walkthrough

- 🌍 **Live Application:** [https://salary-management-incubyte-azure.vercel.app](https://salary-management-incubyte-azure.vercel.app/)
- 🎥 **Video Walkthrough:** [Watch on Loom](https://www.loom.com/share/e7d28311be3d487689e35497699c39cd)

## Notes

Authentication is intentionally excluded from this assessment demo. See [decisions.md](docs/decisions.md) for the rationale and [open-questions.md](docs/open-questions.md) for other assumptions.