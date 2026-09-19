# Trade-offs — ACME Salary Management System

This document records meaningful trade-offs made during the project. Each entry clearly states the choice made and what was given up.

---

## 1. PostgreSQL vs SQLite

| | Option A | Option B |
|-|----------|----------|
| **Choice** | ✅ PostgreSQL (both local and production) | SQLite locally, PostgreSQL in production |
| **Reason** | Same database engine = no environment-parity surprises. PostgreSQL's NUMERIC type, indexes, and aggregation are appropriate for salary analytics. |
| **Trade-off** | PostgreSQL requires local installation (via WSL2 in this project). SQLite requires zero setup. The setup cost is a one-time investment worth making for a realistic development environment. |

---

## 2. Monolith vs Microservices

| | Option A | Option B |
|-|----------|----------|
| **Choice** | ✅ Rails monolith | Microservices (separate analytics service, employee service, etc.) |
| **Reason** | 10,000 employees is a small dataset. A single process with database indexes handles all reads and analytics efficiently. Monolith is simpler to deploy, test, debug, and understand. |
| **Trade-off** | The monolith cannot be independently scaled per concern. If the analytics endpoint became extremely slow, it cannot be independently deployed without affecting employee CRUD. For this scale, this is not a real problem. |

---

## 3. REST vs GraphQL

| | Option A | Option B |
|-|----------|----------|
| **Choice** | ✅ REST JSON API | GraphQL |
| **Reason** | REST is simpler to implement, test, and consume. The frontend has fixed data requirements per view. Over-fetching is not a performance concern at 10,000 employees. |
| **Trade-off** | If the UI needed to display many different combinations of employee fields on different screens, GraphQL would reduce over-fetching. With fixed views and server-side pagination, REST is sufficient. |

---

## 4. Salary History: Append-Only vs Destructive Update

| | Option A | Option B |
|-|----------|----------|
| **Choice** | ✅ Append-only salary history | Destructive update (overwrite current salary) |
| **Reason** | Audit trail is a fundamental expectation of any HR salary management system. History allows HR to see when salaries changed, by how much, and why. |
| **Trade-off** | Requires a separate `salary_histories` table and a JOIN/subquery to retrieve current salary. The `(employee_id, effective_from DESC)` index keeps this fast. |

---

## 5. Server-Side Pagination vs Client-Side

| | Option A | Option B |
|-|----------|----------|
| **Choice** | ✅ Server-side pagination | Load all records to client, paginate in browser |
| **Reason** | Loading 10,000 employees in one API response would result in large payloads (~1-2 MB JSON), slow rendering, and unnecessary memory usage. Server-side pagination keeps each response small (25-100 records). |
| **Trade-off** | The client cannot sort/filter without a new API call. This is the correct behavior — filtering belongs in the database, not in JavaScript on a static dataset. |

---

## 6. Database Aggregation vs Ruby Aggregation

| | Option A | Option B |
|-|----------|----------|
| **Choice** | ✅ SQL GROUP BY / COUNT / SUM / AVG | Load all employees in Ruby, aggregate with `.sum`, `.count`, etc. |
| **Reason** | The database is optimized for aggregation. Loading 10,000 ActiveRecord objects to sum salaries in Ruby would be ~10x slower and use significantly more memory. |
| **Trade-off** | SQL aggregation queries are less immediately readable than Ruby enumerable methods. Mitigated by clearly named query methods and inline comments. |

---

## 7. Authentication: Excluded vs Included

| | Option A | Option B |
|-|----------|----------|
| **Choice** | ✅ No authentication | Devise with JWT token auth |
| **Reason** | The assessment does not specify multi-user requirements. No login is required for a demo with a single HR Manager context. Adding Devise would add significant setup, testing complexity, and frontend token management for zero assessment value. |
| **Trade-off** | The application is **not suitable for production use** without authentication. This is explicitly documented. In a real engagement, authentication would be implemented before any launch. |

---

## 8. Deployment: Render vs Railway vs Heroku vs AWS

| | Render | Railway | Heroku | AWS |
|-|--------|---------|--------|-----|
| **Choice** | ✅ Render | Fallback option | — | — |
| **Reason** | Render provides free/low-cost Static Site + Web Service + PostgreSQL. Supports GitHub Actions auto-deploy. PostgreSQL is managed with no additional configuration. |
| **Trade-off** | Render free tier has cold-start latency (service spins down after inactivity). This is acceptable for an assessment demo. Railway is simpler but has less control over static site deployment. Heroku costs more. AWS has significant setup complexity. |

---

## 9. Departments/Countries as Strings vs Lookup Tables

| | Option A | Option B |
|-|----------|----------|
| **Choice** | ✅ Plain VARCHAR columns on Employee | Separate `departments`, `countries`, `job_titles` tables with foreign keys |
| **Reason** | The application does not need to manage these as entities (no admin UI to create/rename/delete departments). Distinct values for filter dropdowns are queried dynamically. This keeps the schema simple. |
| **Trade-off** | No database-level referential integrity for department/country values. A data entry error (typo) creates a new effective "department." Mitigated by model-level validation against a known list and consistent seed data. |

---

## 10. Currency: No Normalization vs Single Reference Currency

| | Option A | Option B |
|-|----------|----------|
| **Choice** | ✅ Per-currency analytics, no normalization | Normalize all salaries to USD using fixed rates |
| **Reason** | Exchange rates change. Hardcoding a rate introduces inaccuracy. Showing per-currency breakdowns is honest and correct. |
| **Trade-off** | HR cannot see a single "total payroll" number across all currencies in one figure. The dashboard shows payroll totals grouped by currency. If cross-currency comparison is later required, a fixed-rate normalization can be added as an optional view. |
