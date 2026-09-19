# Design Decisions — ACME Salary Management System

This document records meaningful technical decisions made during the project. For each decision, the format is:

> **Decision:** What we chose  
> **Reason:** Why  
> **Alternative considered:** What we could have done instead  
> **Trade-off:** What we give up with this choice

---

## 1. Backend: Ruby on Rails

**Decision:** Use Ruby on Rails as the backend framework in API-only mode.  
**Reason:** This is the target role (ROR-I). Rails provides excellent conventions for building CRUD-heavy APIs quickly and readably. ActiveRecord handles database interactions idiomatically, and the ecosystem (RSpec, FactoryBot, RuboCop) is mature.  
**Alternative considered:** Node.js with Express or NestJS (the candidate's primary experience).  
**Trade-off:** Ruby performance is lower than Node.js, but at 10,000 employees with proper indexes and pagination, this is irrelevant. Rails convention reduces the need for boilerplate configuration.

---

## 2. Database: PostgreSQL from the Start

**Decision:** Use PostgreSQL in both local development and production (no SQLite).  
**Reason:** Using the same database engine locally and in production eliminates an entire class of environment-parity bugs. PostgreSQL's aggregation capabilities, index options, and JSON support are well-suited for salary analytics. Rails' numeric type maps cleanly to PostgreSQL's `NUMERIC`, avoiding floating-point precision issues with salary values.  
**Alternative considered:** SQLite for local development (simpler setup), PostgreSQL only in production.  
**Trade-off:** Local setup requires PostgreSQL to be running (via WSL2 or Docker). This cost is worth the parity benefit.

---

## 3. Architecture: Monolith

**Decision:** Deploy a single Rails application serving all API endpoints.  
**Reason:** 10,000 employees is a small dataset. A single web process with database indexes can serve all analytics and list queries well within acceptable latency. A monolith is easier to deploy, test, understand, and maintain.  
**Alternative considered:** Microservices with separate analytics service, event sourcing, CQRS.  
**Trade-off:** If the system needed to scale to millions of employees with real-time payroll processing, a monolith would become limiting. That is not the case here.

---

## 4. API Style: REST

**Decision:** Use REST with JSON responses.  
**Reason:** REST is straightforward, well-understood, and appropriate for CRUD operations on resources like employees and salaries. Every HTTP client can consume it without special tooling.  
**Alternative considered:** GraphQL — would allow the frontend to request exactly the fields it needs.  
**Trade-off:** REST over-fetches or under-fetches in some cases. At this scale, this is not a performance concern and REST is simpler to implement and test.

---

## 5. Salary History: Append-Only

**Decision:** Salary updates create a new `salary_history` record. The previous salary is never overwritten.  
**Reason:** Audit trail is a basic expectation of any HR system. HR managers need to see when a salary changed, by how much, and why. Destructive updates would lose this information permanently.  
**Alternative considered:** Destructive update — simpler schema (just one `salary` field on `Employee`).  
**Trade-off:** The schema is slightly more complex (a separate `salary_histories` table). Current salary requires a small query (most recent history record). This complexity is worth it for the audit trail.

---

## 6. Current Salary: Derived from Salary History

**Decision:** The current salary is the most recent `SalaryHistory` record by `effective_from` date where `effective_from <= today`.  
**Reason:** This naturally handles future-dated salary changes without a separate "current salary" column that could drift out of sync.  
**Alternative considered:** A `current_salary` column on the `Employee` model, updated atomically with each salary change.  
**Trade-off:** Querying current salary requires a JOIN or subquery. Mitigated by indexing `(employee_id, effective_from)` and eager-loading in the API layer.

---

## 7. Authentication: Excluded

**Decision:** No authentication system is implemented. The application runs in a single HR Manager context.  
**Reason:** The assessment brief asks what questions to raise, not what complexity to add. No requirement for multi-user login was specified. Adding Devise + token auth would add significant complexity for zero product value in an assessment with a single demo user.  
**Alternative considered:** Devise with JWT tokens, HTTP Basic Auth.  
**Trade-off:** The application is not suitable for production use without authentication. This is explicitly called out in requirements.md. In a real engagement, authentication would be added before launch.

---

## 8. Pagination: Server-Side

**Decision:** All list endpoints paginate server-side. The default page size is 25. The maximum is 100.  
**Reason:** Loading all 10,000 employees into the browser in one request would be slow and wasteful. Server-side pagination keeps payloads small and puts the filtering and sorting work in the database (where it belongs).  
**Alternative considered:** Virtual scrolling with a large initial payload on the client.  
**Trade-off:** Users cannot "see all" without iterating pages. In an HR tool, this is not a real use case — users search and filter to find individuals, not browse 10,000 records.

---

## 9. Analytics: Database Aggregation

**Decision:** Analytics (totals, averages, breakdowns) are calculated with SQL GROUP BY / COUNT / SUM / AVG queries. No Ruby-side aggregation of full result sets.  
**Reason:** Loading 10,000 ActiveRecord objects into memory to sum salaries in Ruby would be slow, memory-intensive, and wrong. The database is designed for exactly this kind of aggregation.  
**Alternative considered:** Loading all records in Ruby, aggregating with `.sum`, `.avg`, etc.  
**Trade-off:** SQL aggregation queries are less immediately readable than Ruby code. Mitigated by clearly named query methods with comments.

---

## 10. Frontend: React + Vite + TypeScript

**Decision:** Use React with TypeScript, bundled with Vite. No Next.js.  
**Reason:** The assessment specifies ReactJS/NextJS. Next.js's server-side rendering is not needed for an internal HR tool where SEO and first-paint performance are not priorities. Vite gives fast local development without SSR complexity.  
**Alternative considered:** Next.js (App Router), Create React App (deprecated).  
**Trade-off:** No SSR or static generation. Acceptable for an internal application.

---

## 11. Departments and Countries: String Columns

**Decision:** `department`, `country`, and `job_title` are stored as plain string columns on the `Employee` model, not as foreign keys to lookup tables.  
**Reason:** The assessment scope does not require managing departments or countries as entities (no create/edit/delete for departments). Strings are simpler and the values are retrieved from the database as distinct values when filtering is needed.  
**Alternative considered:** Separate `departments`, `countries`, `job_titles` tables with foreign keys.  
**Trade-off:** No referential integrity enforcement on these fields. Typos could create inconsistent data. Mitigated by seeding with a fixed set of values and validating against an allow-list on the model.

---

## 12. Deployment: Render

**Decision:** Deploy to Render (Static Site + Web Service + Managed PostgreSQL).  
**Reason:** Render provides a free/low-cost tier that supports all three required services natively. GitHub Actions CI can trigger Render auto-deploys. No Kubernetes or container orchestration needed.  
**Alternative considered:** Railway (simpler but less control), Heroku (higher cost), AWS (significant setup cost).  
**Trade-off:** Render free tier may have cold start latency. Acceptable for an assessment demo.
