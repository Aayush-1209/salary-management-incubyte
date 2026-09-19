# Testing Strategy — ACME Salary Management System

## Philosophy

Tests document behavior, not implementation. A test that breaks when we rename a private method is not useful. A test that breaks when a salary can be set to a negative value is exactly what we want.

Tests follow the **Red → Green → Refactor** TDD cycle for important domain behavior. We do not implement first and test later for business logic.

---

## Test Levels

### 1. Model / Domain Specs (RSpec)

**Location:** `spec/models/`  
**Tool:** RSpec + FactoryBot  
**Focus:** ActiveRecord validations, associations, domain methods, business rules  
**Speed:** Fast (no HTTP, no database round-trips beyond what ActiveRecord needs)

These tests verify that the domain rules are correct regardless of how they are exposed. Examples:

- An employee with a missing `email` is invalid
- Two employees cannot share the same `employee_number`
- A salary amount of zero is invalid
- A salary amount of -100 is invalid
- The current salary is the most recent `effective_from` record

### 2. Request Specs (RSpec)

**Location:** `spec/requests/`  
**Tool:** RSpec  
**Focus:** HTTP API contracts — request/response format, status codes, parameter handling, error responses  
**Speed:** Medium (hits the database, goes through the full Rails stack)

These are integration tests that verify the API behaves correctly from the outside. They do not test UI. Examples:

- `GET /api/employees` returns 200 with paginated results
- `GET /api/employees?search=john` returns matching employees
- `GET /api/employees/999` returns 404 when employee doesn't exist
- `POST /api/employees/:id/salaries` with invalid amount returns 422 with error details
- `POST /api/employees/:id/salaries` creates a history record and returns 201

### 3. React Component Tests (Vitest + React Testing Library)

**Location:** `frontend/src/**/*.test.tsx`  
**Tool:** Vitest + React Testing Library  
**Focus:** User-visible behavior — what renders, what happens on interaction, API call expectations  
**Speed:** Fast (JSDOM, mocked API)

These tests simulate what a user does and verify the outcome. They do not test implementation details like state variable names or internal component structure. Examples:

- The employee list renders employee names
- Typing in the search box triggers a filtered list
- Clicking "Next" on pagination updates the list
- The salary update form shows an error when amount is empty
- The salary update form shows a success message after submission
- The dashboard displays total employee count and average salary

---

## TDD Workflow

For every important business behavior:

```
1. Write a failing test that describes the expected behavior
   (rspec spec/models/employee_spec.rb -- it 'is invalid without email')

2. Run the test — confirm it fails for the right reason (RED)

3. Implement the minimum code to make the test pass

4. Run the test again — confirm it passes (GREEN)

5. Refactor if needed — clean up code without breaking tests

6. Run the full suite — confirm nothing was broken
```

We apply TDD strictly for:
- Model validations
- Salary domain rules (current salary, history preservation, effective date behavior)
- API error handling

We apply TDD more loosely for:
- View rendering (test what renders, implement the component)
- Analytics aggregation queries (write the expected output spec, implement the SQL)

---

## What We Do NOT Test

- Rails framework internals (routing conventions, built-in callbacks)
- Database migrations themselves
- Seed data content
- Third-party gem behavior
- Implementation details (internal variable names, private method names)
- Every possible HTTP edge case (focus on the important behavior)

---

## Factory Strategy

**Tool:** FactoryBot

We define minimal factories with sensible defaults. Traits are used for specific states.

```ruby
# spec/factories/employees.rb
FactoryBot.define do
  factory :employee do
    sequence(:employee_number) { |n| "EMP-#{n.to_s.rjust(5, '0')}" }
    sequence(:email) { |n| "employee#{n}@acme.com" }
    first_name { "Jane" }
    last_name  { "Doe" }
    country    { "India" }
    department { "Engineering" }
    job_title  { "Software Engineer" }
    level      { "Mid" }
    currency   { "INR" }
    hired_on   { 2.years.ago.to_date }

    trait :with_salary do
      after(:create) do |employee|
        create(:salary_history, employee: employee)
      end
    end
  end
end
```

---

## Test Coverage Targets

We aim for meaningful coverage of:

| Area | Target |
|------|--------|
| Employee model validations | All required fields + uniqueness |
| Salary domain rules | Amount > 0, effective_from, history preservation |
| Employee API endpoints | GET list, GET detail, filters, pagination, 404 |
| Salary API endpoints | POST (create), validation errors, 422, 201 |
| Analytics endpoint | Returns expected shape with correct values |
| React employee list | Renders, search, pagination |
| React employee detail | Renders employee + salary |
| React salary form | Validation, success, error |
| React dashboard | Renders analytics data |

We do **not** target 100% line coverage. Coverage for its own sake creates tests that hinder refactoring.

---

## Running Tests

```bash
# Backend — all specs
bundle exec rspec

# Backend — single file
bundle exec rspec spec/models/employee_spec.rb

# Backend — with coverage report
COVERAGE=true bundle exec rspec

# Frontend — all tests
npm test

# Frontend — watch mode
npm run test:watch

# Frontend — coverage
npm run test:coverage
```

---

## CI Integration

All tests run automatically on GitHub Actions for every push and PR. A failing test or lint check blocks the merge. See `.github/workflows/ci.yml`.
