require 'rails_helper'

RSpec.describe 'Api::Employees::Salaries', type: :request do
  let(:employee) { create(:employee) }

  describe 'GET /api/employees/:employee_id/salaries' do
    before do
      create(:salary_history, employee: employee, effective_date: 1.year.ago.to_date, gross_salary: 60_000)
      create(:salary_history, employee: employee, effective_date: 1.month.ago.to_date, gross_salary: 75_000)
    end

    it 'returns 200' do
      get "/api/employees/#{employee.id}/salaries"
      expect(response).to have_http_status(:ok)
    end

    it 'returns salary history ordered newest first' do
      get "/api/employees/#{employee.id}/salaries"
      salaries = response.parsed_body['salaries']
      expect(salaries.length).to eq(2)
      expect(salaries.first['gross_salary'].to_f).to eq(75_000.0)
      expect(salaries.last['gross_salary'].to_f).to eq(60_000.0)
    end

    it 'returns 404 if employee does not exist' do
      get '/api/employees/999999/salaries'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/employees/:employee_id/salaries' do
    let(:valid_attributes) do
      {
        salary: {
          gross_salary: 80_000,
          effective_date: Date.current,
          reason: 'merit_increase',
          notes: 'Annual performance review'
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new SalaryHistory' do
        expect {
          post "/api/employees/#{employee.id}/salaries", params: valid_attributes
        }.to change(SalaryHistory, :count).by(1)
      end

      it 'returns 201 status and the created salary' do
        post "/api/employees/#{employee.id}/salaries", params: valid_attributes
        expect(response).to have_http_status(:created)
        
        salary = response.parsed_body['salary']
        expect(salary['gross_salary'].to_f).to eq(80_000.0)
        expect(salary['reason']).to eq('merit_increase')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) do
        {
          salary: {
            gross_salary: -100, # Invalid
            effective_date: nil
          }
        }
      end

      it 'does not create a SalaryHistory' do
        expect {
          post "/api/employees/#{employee.id}/salaries", params: invalid_attributes
        }.to change(SalaryHistory, :count).by(0)
      end

      it 'returns 422 status with errors' do
        post "/api/employees/#{employee.id}/salaries", params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
        
        errors = response.parsed_body['errors']
        expect(errors).to include('gross_salary')
        expect(errors).to include('effective_date')
      end
    end
    
    it 'returns 404 if employee does not exist' do
      post '/api/employees/999999/salaries', params: valid_attributes
      expect(response).to have_http_status(:not_found)
    end
  end
end
