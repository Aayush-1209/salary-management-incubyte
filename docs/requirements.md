# Requirements — ACME Salary Management System

## Goal

Provide ACME organization's HR team with a web-based tool that replaces Excel-based salary management, allowing HR managers to view, search, filter, and manage salary information for approximately 10,000 employees across multiple countries.

---

## Primary User

**HR Manager** — a non-technical user who currently manages employee salary data in spreadsheets and needs a more reliable, queryable, and auditable system.

---

## Problem

- Salary data lives in Excel spreadsheets, making it difficult to search, filter, and aggregate
- No audit trail when salaries change
- No single source of truth across multiple countries and departments
- No way to quickly answer organization-wide salary questions (e.g., average salary by department, payroll by country)

---

## In Scope

- Employee directory with search, filter, sort, and pagination
- Employee detail view showing current salary and employment information
- Salary management: view and update an employee's salary
- Salary history: retain a record of past salary values when a salary is changed
- Salary analytics dashboard: organization-wide headcount, payroll totals, breakdowns by country and department
- Seed data: 10,000 synthetic employees for realistic demonstration

---

## Core User Workflows

1. **Browse employees** — Open the employee list, search by name, filter by country or department, sort by name or salary, paginate through results
2. **View employee** — Open an employee's profile to see their personal details, current salary, and salary history
3. **Update salary** — Change an employee's salary, provide a reason and effective date, and have the old salary preserved in history
4. **Understand the organization** — Open the dashboard to see total headcount, total payroll, average/median salary, and breakdowns by country and department

---

## Non-Functional Requirements

- **Performance:** The list and analytics endpoints must respond acceptably with 10,000 employees. No full table scans on the hot path. Pagination enforced server-side.
- **Data integrity:** Salary updates must be transactional. No partial writes.
- **Security:** No hardcoded credentials. Environment variables for all secrets. Parameterized queries (ActiveRecord handles this). Reasonable CORS configuration.
- **Maintainability:** Idiomatic Rails, readable Ruby, typed TypeScript, meaningful test coverage focused on behavior.
- **Deployment:** Fully reproducible on Render (PostgreSQL + Rails API + React static site).

---

## Out of Scope

- Multi-user authentication and role-based access control
- Approval workflows for salary changes
- Real-time notifications
- Payroll processing or integration with payroll systems
- HR onboarding/offboarding workflows
- Document management
- Mobile-native applications
- Internationalization / localization of the UI
- Real employee data (only synthetic seed data)

---

## Assumptions

- A single HR Manager context is sufficient; no login is required for the assessment demo
- Salary comparisons across countries will be shown in each employee's native currency; no currency normalization is performed (see open questions)
- Salary history is preserved: updating a salary creates a new record, not a destructive replacement
- Effective dates are recorded on salary records to support future date-based queries
- The assessment dataset of 10,000 employees is read-only seed data and does not need to be editable in bulk
- Departments, countries, and job titles are stored as plain strings (no separate lookup tables), keeping the model simple for this scale

---

## Open Questions / Working Assumptions

The following items are unresolved or based on working assumptions made to unblock development:

- **Multi-currency analytics:** Showing per-currency breakdowns; no normalization across currencies. Can revisit if a single-currency view is required.
- **Authentication:** Excluded from assessment scope. Single HR Manager context assumed.
- **Approval workflow:** Assumed not required. Salary changes are applied directly by the HR Manager.
- **Employee CRUD:** MVP scope is read + salary update. Creating/deleting employees is out of scope.
- **Salary distribution:** Median and average will be shown; histogram buckets are stretch goals.
