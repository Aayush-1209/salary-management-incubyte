require 'rails_helper'

RSpec.describe 'Api::Employees', type: :request do
  let!(:employees) do
    [
      create(:employee, country: 'India',         department: 'Engineering', active: true),
      create(:employee, country: 'United States', department: 'Engineering', active: true),
      create(:employee, country: 'India',         department: 'Finance',     active: true),
      create(:employee, :inactive)
    ]
  end

  # ── GET /api/employees ────────────────────────────────────────────────────
  describe 'GET /api/employees' do
    it 'returns 200' do
      get '/api/employees'
      expect(response).to have_http_status(:ok)
    end

    it 'returns only active employees by default' do
      get '/api/employees'
      ids = response.parsed_body['employees'].map { |e| e['id'] }
      expect(ids).not_to include(employees.last.id)
    end

    it 'returns employees with expected fields' do
      get '/api/employees'
      employee = response.parsed_body['employees'].first
      expect(employee.keys).to include(
        'id', 'employee_number', 'email', 'first_name', 'last_name',
        'full_name', 'country', 'department', 'job_title', 'level',
        'currency', 'hired_on', 'active', 'current_gross_salary'
      )
    end

    it 'returns pagination metadata' do
      get '/api/employees'
      meta = response.parsed_body['meta']
      expect(meta.keys).to include('total', 'page', 'per_page', 'total_pages')
    end

    context 'with country filter' do
      it 'returns employees for the given country' do
        get '/api/employees', params: { country: 'India' }
        countries = response.parsed_body['employees'].map { |e| e['country'] }
        expect(countries).to all(eq('India'))
      end
    end

    context 'with department filter' do
      it 'returns employees for the given department' do
        get '/api/employees', params: { department: 'Engineering' }
        departments = response.parsed_body['employees'].map { |e| e['department'] }
        expect(departments).to all(eq('Engineering'))
      end
    end

    context 'with search param' do
      it 'returns employees matching name or email' do
        target = employees.first
        get '/api/employees', params: { search: target.first_name }
        ids = response.parsed_body['employees'].map { |e| e['id'] }
        expect(ids).to include(target.id)
      end
    end

    context 'with pagination' do
      it 'respects per_page param' do
        get '/api/employees', params: { per_page: 2 }
        expect(response.parsed_body['employees'].length).to eq(2)
      end
    end
  end

  # ── GET /api/employees/:id ────────────────────────────────────────────────
  describe 'GET /api/employees/:id' do
    let(:employee) { employees.first }

    before do
      create(:salary_history, employee: employee, effective_date: 1.year.ago.to_date, gross_salary: 60_000)
      create(:salary_history, employee: employee, effective_date: 1.month.ago.to_date, gross_salary: 75_000)
    end

    it 'returns 200' do
      get "/api/employees/#{employee.id}"
      expect(response).to have_http_status(:ok)
    end

    it 'returns the employee' do
      get "/api/employees/#{employee.id}"
      expect(response.parsed_body['employee']['id']).to eq(employee.id)
    end

    it 'includes salary history ordered newest first' do
      get "/api/employees/#{employee.id}"
      salaries = response.parsed_body['employee']['salary_histories']
      expect(salaries.length).to eq(2)
      expect(salaries.first['gross_salary'].to_f).to eq(75_000.0)
    end

    it 'returns 404 for unknown employee' do
      get '/api/employees/999999'
      expect(response).to have_http_status(:not_found)
    end
  end
end
