FactoryBot.define do
  factory :employee do
    sequence(:employee_number) { |n| "EMP-#{n.to_s.rjust(5, '0')}" }
    sequence(:email)           { |n| "employee#{n}@acme.com" }
    first_name  { "Jane" }
    last_name   { "Doe" }
    country     { "India" }
    department  { "Engineering" }
    job_title   { "Software Engineer" }
    level       { "Mid" }
    currency    { "INR" }
    hired_on    { 2.years.ago.to_date }
    active      { true }

    trait :inactive do
      active { false }
    end

    trait :senior do
      level     { "Senior" }
      job_title { "Senior Software Engineer" }
    end

    trait :us_based do
      country  { "United States" }
      currency { "USD" }
    end
  end

  factory :salary_history do
    association :employee
    gross_salary   { 75_000.00 }
    effective_date { 1.month.ago.to_date }
    reason         { "hire" }
    notes          { nil }

    trait :promotion do
      reason       { "promotion" }
      gross_salary { 90_000.00 }
    end

    trait :merit_increase do
      reason       { "merit_increase" }
      gross_salary { 80_000.00 }
    end
  end
end
