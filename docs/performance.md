# Performance — ACME Salary Management System

## Expected Scale

The system is designed for approximately 10,000 employees. This is a small dataset by any database standard. A well-indexed PostgreSQL table with 10,000 rows responds to queries in single-digit milliseconds. No distributed infrastructure is needed.

---

## Expected Access Patterns

| Pattern | Frequency | Notes |
|---------|-----------|-------|
| Employee list (paginated) | High | 25 records per page, filtered/sorted |
| Employee search | High | Full-name or partial-name search |
| Employee detail | Medium | Single record + current salary |
| Salary update | Low | Single write per interaction |
| Analytics dashboard | Medium | Aggregation queries on full table |

---

## Indexes

Indexes are the primary performance tool for this scale.

### `employees` table

| Index | Type | Purpose |
|-------|------|---------|
| `id` (PK) | B-tree | Standard primary key lookup |
| `employee_number` | Unique B-tree | HR identifier lookup |
| `email` | Unique B-tree | Uniqueness check, lookup |
| `country` | B-tree | Filter by country |
| `department` | B-tree | Filter by department |
| `(first_name, last_name)` | B-tree | Name-based search support |

### `salary_histories` table

| Index | Type | Purpose |
|-------|------|---------|
| `id` (PK) | B-tree | Standard primary key lookup |
| `employee_id` | B-tree | Foreign key join |
| `(employee_id, effective_from DESC)` | B-tree | Efficient current salary retrieval |

---

## Pagination

All list endpoints enforce server-side pagination.

- Default page size: **25 records**
- Maximum page size: **100 records**
- Implementation: `LIMIT` + `OFFSET` in SQL via ActiveRecord `.page().per()`

At 10,000 employees, even the worst-case full-table scan for a sorted list completes in well under 100 ms with appropriate indexes. Pagination keeps response payloads small (~5 KB for 25 employees with basic fields).

---

## Analytics Aggregation

Analytics queries use SQL `GROUP BY`, `COUNT`, `SUM`, and `AVG` directly.

```sql
-- Total employees and payroll by country (example)
SELECT
  e.country,
  e.currency,
  COUNT(e.id) AS employee_count,
  SUM(sh.amount) AS total_payroll,
  AVG(sh.amount) AS avg_salary
FROM employees e
JOIN salary_histories sh ON sh.id = (
  SELECT id FROM salary_histories
  WHERE employee_id = e.id
    AND effective_from <= CURRENT_DATE
  ORDER BY effective_from DESC
  LIMIT 1
)
GROUP BY e.country, e.currency
ORDER BY e.country;
```

This query runs against 10,000 employees in well under 1 second on any modern server. Loading all 10,000 ActiveRecord objects into Ruby to aggregate in Ruby would be ~10x slower and use significantly more memory.

---

## N+1 Prevention

The primary N+1 risk is loading salary data for a list of employees. This is prevented by:

1. **Employee list:** Current salary is not shown on the list view (only in the detail view), eliminating the N+1 entirely
2. **Employee detail:** `Employee.includes(:salary_histories)` loads both in one query when showing the detail page
3. **Analytics:** All aggregations are single SQL queries with JOINs, never Ruby-side loops over employees

The Rails `bullet` gem may be added in development to detect any accidentally introduced N+1 queries.

---

## Search Performance

Employee search (by name) uses a `ILIKE` query:

```sql
WHERE (first_name ILIKE '%john%' OR last_name ILIKE '%john%')
```

At 10,000 rows, a leading wildcard `ILIKE '%term%'` cannot use a B-tree index. However, at this scale, a full-table name scan completes in <50 ms. No full-text search engine is needed.

If the scale were to grow to millions of employees, PostgreSQL full-text search (`tsvector` / `tsquery`) would be the appropriate next step without introducing Elasticsearch.

---

## Payload Size

| Endpoint | Estimated Response Size | Notes |
|----------|------------------------|-------|
| `GET /api/employees?per_page=25` | ~8 KB | 25 employees, basic fields |
| `GET /api/employees/:id` | ~2 KB | One employee + salary history |
| `GET /api/analytics/summary` | ~2 KB | Aggregated numbers only |
| `GET /api/employees?per_page=100` | ~32 KB | Maximum page size |

No endpoint returns the full 10,000-employee dataset. The `per_page` maximum of 100 is enforced server-side.

---

## Known Limitations

1. **Leading-wildcard search** does not use an index. Acceptable at 10,000 rows; would need `pg_trgm` or full-text search at millions of rows.
2. **Current salary subquery** on analytics is potentially heavy if not handled carefully. The composite index on `(employee_id, effective_from DESC)` mitigates this.
3. **Cold-start latency** on Render free tier: the web service sleeps after inactivity. First request after sleep may take 10-30 seconds. This is a hosting-tier limitation, not an application problem.
4. **No caching:** The analytics dashboard queries run on every request. At 10,000 employees, this is fine. At higher scale, a simple `Rails.cache` with a 60-second TTL on the analytics query would be the first optimization.

---

## Benchmark Notes

> No benchmark numbers are claimed here. All performance statements above are based on known PostgreSQL behavior at small table sizes and general principles, not measured results. Actual benchmarks will be recorded here once the application is running.
