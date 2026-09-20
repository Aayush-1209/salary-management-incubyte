require 'rails_helper'

RSpec.describe 'Api::Analytics::Summary', type: :request do
  describe 'GET /api/analytics/summary' do
    before do
      # Department 1: Engineering (2 active, 1 inactive)
      e1 = create(:employee, department: 'Engineering', active: true, currency: 'USD')
      create(:salary_history, employee: e1, effective_date: 1.month.ago, gross_salary: 100_000)

      e2 = create(:employee, department: 'Engineering', active: true, currency: 'USD')
      create(:salary_history, employee: e2, effective_date: 1.month.ago, gross_salary: 80_000)

      e3 = create(:employee, department: 'Engineering', active: false, currency: 'USD')
      create(:salary_history, employee: e3, effective_date: 1.month.ago, gross_salary: 90_000)

      # Department 2: HR (1 active)
      e4 = create(:employee, department: 'HR', active: true, currency: 'EUR')
      create(:salary_history, employee: e4, effective_date: 1.month.ago, gross_salary: 60_000)

      # For active Engineering employees, total current salary is 180,000 USD
      # For active HR employees, total current salary is 60,000 EUR
    end

    it 'returns 200 status' do
      get '/api/analytics/summary'
      expect(response).to have_http_status(:ok)
    end

    it 'returns overall summary including active employee count and total departments' do
      get '/api/analytics/summary'

      summary = response.parsed_body['summary']
      expect(summary['total_employees']).to eq(3) # Only active ones
      expect(summary['total_departments']).to eq(2)
    end

    it 'returns department wise breakdowns' do
      get '/api/analytics/summary'

      departments = response.parsed_body['summary']['departments']
      expect(departments).to be_an(Array)
      expect(departments.length).to eq(2)

      engineering = departments.find { |d| d['name'] == 'Engineering' }
      expect(engineering['employee_count']).to eq(2)
      expect(engineering['total_salary']).to eq('180000.0')
      expect(engineering['currency']).to eq('USD')

      hr = departments.find { |d| d['name'] == 'HR' }
      expect(hr['employee_count']).to eq(1)
      expect(hr['total_salary']).to eq('60000.0')
      expect(hr['currency']).to eq('EUR')
    end
  end
end
