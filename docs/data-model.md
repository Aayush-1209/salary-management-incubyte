# Data Model — ACME Salary Management System

## Overview

The domain consists of two primary entities: `Employee` and `SalaryHistory`. The current salary is the most recent `SalaryHistory` record with `effective_from <= today`. There is no separate "current salary" column — it is derived from history.

---

## Entity Relationship Diagram

```
┌──────────────────────────────────────┐
│              employees               │
├──────────────────────────────────────┤
│ id              BIGINT  PK           │
│ employee_number VARCHAR  UNIQUE NN   │
│ first_name      VARCHAR  NN          │
│ last_name       VARCHAR  NN          │
│ email           VARCHAR  UNIQUE NN   │
│ country         VARCHAR  NN          │
│ department      VARCHAR  NN          │
│ job_title       VARCHAR  NN          │
│ level           VARCHAR  NN          │
│ currency        CHAR(3)  NN          │
│ hired_on        DATE     NN          │
│ created_at      TIMESTAMP NN         │
│ updated_at      TIMESTAMP NN         │
└──────────────────┬───────────────────┘
                   │ has many
                   │
┌──────────────────▼───────────────────┐
│            salary_histories          │
├──────────────────────────────────────┤
│ id              BIGINT  PK           │
│ employee_id     BIGINT  FK NN        │
│ amount          NUMERIC(15,2) NN     │
│ currency        CHAR(3)  NN          │
│ effective_from  DATE     NN          │
│ reason          TEXT     (optional)  │
│ created_at      TIMESTAMP NN         │
└──────────────────────────────────────┘
```

---

## Entities

### Employee

Represents a single employee in the ACME organization.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | BIGINT | PK, auto-increment | Internal identifier |
| `employee_number` | VARCHAR(20) | UNIQUE, NOT NULL | HR-assigned identifier (e.g., EMP-00001) |
| `first_name` | VARCHAR(100) | NOT NULL | Legal first name |
| `last_name` | VARCHAR(100) | NOT NULL | Legal last name |
| `email` | VARCHAR(255) | UNIQUE, NOT NULL | Work email address |
| `country` | VARCHAR(100) | NOT NULL | Country of employment (e.g., "India", "USA") |
| `department` | VARCHAR(100) | NOT NULL | Organizational department (e.g., "Engineering") |
| `job_title` | VARCHAR(100) | NOT NULL | Job title (e.g., "Software Engineer") |
| `level` | VARCHAR(50) | NOT NULL | Seniority level (e.g., "Junior", "Senior", "Lead") |
| `currency` | CHAR(3) | NOT NULL | ISO 4217 currency code (e.g., "INR", "USD") |
| `hired_on` | DATE | NOT NULL | Date employee joined ACME |
| `created_at` | TIMESTAMP | NOT NULL | Record creation time |
| `updated_at` | TIMESTAMP | NOT NULL | Record last modified time |

**Notes:**
- `employee_number` is the human-readable identifier shown in the UI
- `currency` on the employee defines their primary/default salary currency and must match the most recent `SalaryHistory.currency`
- `country`, `department`, `job_title`, and `level` are plain strings (not foreign keys) for simplicity at this scale

### SalaryHistory

Represents a single salary record. New records are appended on every salary change — records are never updated or deleted.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | BIGINT | PK, auto-increment | Internal identifier |
| `employee_id` | BIGINT | FK → employees.id, NOT NULL | Associated employee |
| `amount` | NUMERIC(15,2) | NOT NULL, > 0 | Salary amount in `currency` |
| `currency` | CHAR(3) | NOT NULL | ISO 4217 currency code |
| `effective_from` | DATE | NOT NULL | Date from which this salary applies |
| `reason` | TEXT | optional | HR notes on why salary changed |
| `created_at` | TIMESTAMP | NOT NULL | When this record was entered into the system |

**Notes:**
- The current salary is: `SalaryHistory.where(employee_id:).where('effective_from <= ?', Date.today).order(effective_from: :desc).first`
- `amount` uses `NUMERIC(15,2)` (not `FLOAT`) to avoid floating-point precision issues with money
- `currency` is recorded on each salary record to support theoretical currency changes at salary update time

---

## Relationships

- `Employee` has many `SalaryHistory` records (`has_many :salary_histories`)
- `SalaryHistory` belongs to one `Employee` (`belongs_to :employee`)
- When an `Employee` is destroyed, their `SalaryHistory` records are also destroyed (`dependent: :destroy`)

---

## Indexes

| Table | Index | Type | Reason |
|-------|-------|------|--------|
| `employees` | `employee_number` | UNIQUE | Fast lookup by HR identifier |
| `employees` | `email` | UNIQUE | Fast lookup, uniqueness check |
| `employees` | `country` | B-tree | Filter by country |
| `employees` | `department` | B-tree | Filter by department |
| `employees` | `(first_name, last_name)` | B-tree | Name search support |
| `salary_histories` | `employee_id` | B-tree | FK join, current salary lookup |
| `salary_histories` | `(employee_id, effective_from DESC)` | B-tree | Efficient current salary query |

---

## Design Rationale

### Why not a `current_salary` column on Employee?

A denormalized `current_salary` on the `Employee` table would need to be kept in sync with `SalaryHistory`. With a transaction that creates a new `SalaryHistory` record, there would be two writes to keep atomic. The indexed `(employee_id, effective_from DESC)` query is fast enough to not require denormalization at 10,000 employees.

### Why NUMERIC(15,2) for amount?

Salary values must not lose precision due to floating-point representation. `NUMERIC(15,2)` stores exact decimal values up to 999,999,999,999,999.99 — sufficient for any realistic salary in any currency. `FLOAT` should never be used for money.

### Why currency on both Employee and SalaryHistory?

The `currency` field on `Employee` represents the employee's primary currency for display purposes without requiring a join to `salary_histories`. The `currency` on `SalaryHistory` records the currency at the time of each salary entry, which supports (in theory) currency changes and preserves historical accuracy.

### Why not separate tables for Department, Country, JobTitle?

The assessment does not require managing these as standalone entities (no create/edit/delete UI for departments). Storing as strings keeps the model simple. Distinct values are queried from the database dynamically for filter dropdowns. If ACME needed to rename a department across all employees, a migration or admin API could handle it — that is out of scope for this assessment.

---

## Domain Invariants

1. Every employee must have at least one `SalaryHistory` record (seeded on creation)
2. `SalaryHistory.amount` must be greater than zero
3. `SalaryHistory.effective_from` must not be in the future when created (or if allowed, it does not affect the current salary display until that date arrives)
4. `employee_number` and `email` must be unique across all employees
5. `currency` must be a valid 3-character ISO 4217 code
