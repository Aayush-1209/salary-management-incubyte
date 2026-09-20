# frozen_string_literal: true

puts "Clearing existing data..."
SalaryHistory.delete_all
Employee.delete_all

# Constants for generating realistic data
DEPARTMENTS = %w[Engineering Sales Marketing HR Finance Product Design Legal Customer_Support Operations].freeze
COUNTRIES   = %w[United_States India United_Kingdom Canada Germany Australia Singapore Japan Brazil South_Africa].freeze
LEVELS      = Employee::LEVELS # ["Junior", "Mid", "Senior", "Staff", "Principal"]
CURRENCIES  = {
  'United_States'  => 'USD',
  'India'          => 'INR',
  'United_Kingdom' => 'GBP',
  'Canada'         => 'CAD',
  'Germany'        => 'EUR',
  'Australia'      => 'AUD',
  'Singapore'      => 'SGD',
  'Japan'          => 'JPY',
  'Brazil'         => 'BRL',
  'South_Africa'   => 'ZAR'
}.freeze

FIRST_NAMES = %w[James Mary John Patricia Robert Jennifer Michael Linda William Elizabeth David Barbara Richard Susan Joseph Jessica Thomas Sarah Charles Karen Christopher Nancy Daniel Lisa Matthew Betty Anthony Margaret Mark Sandra Donald Ashley Steven Kimberly Paul Emily Andrew Donna Joshua Michelle Kenneth Carol Kevin Amanda Brian Melissa Edward Deborah Ronald Stephanie].freeze
LAST_NAMES  = %w[Smith Johnson Williams Brown Jones Garcia Miller Davis Rodriguez Martinez Hernandez Lopez Gonzalez Wilson Anderson Thomas Taylor Moore Jackson Martin Lee Perez Thompson White Harris Sanchez Clark Ramirez Lewis Robinson Walker Young Allen King Wright Scott Torres Nguyen Hill Flores Green Adams Nelson Baker Hall Rivera Campbell Mitchell Carter Roberts].freeze
JOB_TITLES  = %w[Engineer Analyst Manager Specialist Director Coordinator Consultant Lead Architect Representative].freeze

TOTAL_EMPLOYEES = 10_000
BATCH_SIZE = 1000

puts "Generating #{TOTAL_EMPLOYEES} employees in batches of #{BATCH_SIZE}..."

employees_data = []
salaries_data = []

current_time = Time.current

TOTAL_EMPLOYEES.times do |i|
  first_name = FIRST_NAMES.sample
  last_name = LAST_NAMES.sample
  country = COUNTRIES.sample
  department = DEPARTMENTS.sample
  level = LEVELS.sample
  
  # Ensure unique email by appending the index
  email = "#{first_name.downcase}.#{last_name.downcase}.#{i}@acme.com"
  
  # Ensure unique employee number
  emp_num = "EMP-#{format('%06d', i + 1)}"
  
  hired_on = rand(1..10).years.ago.to_date
  
  employees_data << {
    employee_number: emp_num,
    first_name: first_name,
    last_name: last_name,
    email: email,
    country: country.sub('_', ' '),
    department: department.sub('_', ' '),
    job_title: "#{level} #{JOB_TITLES.sample}",
    level: level,
    currency: CURRENCIES[country],
    hired_on: hired_on,
    active: rand < 0.95, # 95% active
    created_at: current_time,
    updated_at: current_time
  }
end

# Insert Employees in batches
puts "Inserting Employees..."
employees_data.each_slice(BATCH_SIZE) do |batch|
  Employee.insert_all(batch)
end

# Now we need the employee IDs to create salary histories
puts "Fetching inserted employee IDs..."
# Using pluck is memory efficient
employee_records = Employee.pluck(:id, :hired_on, :level)

puts "Generating Salary Histories..."
employee_records.each do |id, hired_on, level|
  # Base salary depends on level
  base_salary = case level
                when 'Junior' then 50_000
                when 'Mid' then 80_000
                when 'Senior' then 120_000
                when 'Staff' then 160_000
                when 'Principal' then 200_000
                else 100_000
                end
                
  # Add some randomness to base salary
  salary_amount = base_salary + rand(-10_000..20_000)

  # Initial Hire Salary
  salaries_data << {
    employee_id: id,
    gross_salary: salary_amount,
    effective_date: hired_on,
    reason: 'hire',
    notes: 'Initial starting salary',
    created_at: current_time,
    updated_at: current_time
  }

  # If they were hired more than 2 years ago, give them a promotion/merit increase 1 year ago
  if hired_on < 2.years.ago.to_date
    salaries_data << {
      employee_id: id,
      gross_salary: salary_amount * 1.15, # 15% bump
      effective_date: 1.year.ago.to_date,
      reason: %w[promotion merit_increase].sample,
      notes: 'Annual review increase',
      created_at: current_time,
      updated_at: current_time
    }
  end
end

puts "Inserting Salary Histories..."
salaries_data.each_slice(BATCH_SIZE) do |batch|
  SalaryHistory.insert_all(batch)
end

puts "Done! Seeded #{Employee.count} employees and #{SalaryHistory.count} salary histories."
