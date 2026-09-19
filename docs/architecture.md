# Architecture — ACME Salary Management System

## Overview

The system uses a straightforward three-tier architecture: a React frontend, a Rails API backend, and a PostgreSQL database. All three tiers run as separate services and communicate over HTTP.

```
┌─────────────────────────────┐
│   React + TypeScript        │
│   (Vite SPA)                │
│   Render Static Site        │
└──────────┬──────────────────┘
           │ HTTP REST
           │ (JSON)
┌──────────▼──────────────────┐
│   Ruby on Rails             │
│   API-only mode             │
│   Render Web Service        │
└──────────┬──────────────────┘
           │ ActiveRecord
           │ (TCP/IP)
┌──────────▼──────────────────┐
│   PostgreSQL                │
│   Render Managed Database   │
└─────────────────────────────┘
```

---

## Why a Monolith?

The assessment explicitly discourages over-engineering. At 10,000 employees, a single Rails process handling all API requests is well within comfortable capacity. PostgreSQL with proper indexes handles the analytics aggregation efficiently without a separate data warehouse. A monolith is:

- Simpler to deploy (one web service, not many)
- Simpler to test (no network boundaries between components)
- Simpler to understand (reviewers can read the entire codebase in one sitting)
- Appropriate for an internal HR tool with a small user base (one HR team)

Microservices, Kafka, Redis caching, or an Elasticsearch layer would add significant complexity for no practical benefit at this scale.

---

## Frontend Responsibility

The React SPA is responsible for:

- Rendering the HR Manager interface (dashboard, employee list, employee detail, salary update)
- Managing UI state (loading, error, empty states)
- Calling the Rails REST API to fetch and mutate data
- Enforcing client-side form validation before API calls
- Displaying TypeScript-typed API responses

The frontend does **not** contain business logic. Validation rules and domain behavior live in the Rails backend.

**Technology:** React 18, TypeScript, Vite, React Testing Library, Vitest, ESLint

---

## Backend Responsibility

The Rails API (API-only mode) is responsible for:

- Receiving and validating HTTP requests
- Enforcing domain rules (salary validations, required fields, effective date logic)
- Querying and mutating the PostgreSQL database via ActiveRecord
- Returning consistent JSON responses
- Performing server-side pagination, filtering, sorting, and aggregation
- Protecting against invalid inputs (strong parameters, model validations)

**Technology:** Ruby 3.3, Rails 7.1 (API mode), RSpec, FactoryBot, RuboCop

---

## Database Responsibility

PostgreSQL is responsible for:

- Persistent storage of employee and salary records
- Enforcing NOT NULL and UNIQUE constraints at the database level
- Index-based fast lookups (employee_number, email, country, department)
- Aggregation queries for analytics (GROUP BY, COUNT, SUM, AVG)
- Transactional consistency for salary updates

**Technology:** PostgreSQL 16

---

## API Boundary

The frontend and backend communicate via a JSON REST API. Key conventions:

- Base path: `/api/`
- Resources: `/api/employees`, `/api/employees/:id`, `/api/employees/:id/salaries`
- Analytics: `/api/analytics/summary`
- Health: `/api/health`
- Pagination: `page` and `per_page` query parameters
- Filtering: `country`, `department`, `search` query parameters
- Sorting: `sort_by`, `sort_dir` query parameters
- HTTP status codes: 200, 201, 204, 400, 404, 422

CORS is configured to allow requests only from the known frontend origin.

---

## Deployment Architecture

```
GitHub Repository
       │
       ├─ push/PR → GitHub Actions CI
       │            (RSpec + RuboCop + Vitest + ESLint)
       │
       └─ Render Auto-Deploy
            ├─ Render Static Site  (frontend)
            ├─ Render Web Service  (Rails backend)
            └─ Render PostgreSQL   (managed database)
```

Environment variables (DATABASE_URL, RAILS_MASTER_KEY, FRONTEND_URL) are set in Render's service configuration, never committed to the repository.

---

## Testing Approach

| Layer | Tool | Focus |
|-------|------|-------|
| Ruby model specs | RSpec | Domain rules, validations, associations |
| Ruby request specs | RSpec | API contracts, HTTP status, JSON structure |
| React component tests | Vitest + RTL | User behavior, form interaction, API integration |
| Linting | RuboCop + ESLint | Code quality, style consistency |
| CI | GitHub Actions | Automated gate on every push/PR |

TDD is followed for important business behavior: write a failing test, implement minimum passing code, refactor.
