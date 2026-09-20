module Api
  module Employees
    class SalariesController < ApplicationController
      before_action :set_employee

      def index
        salaries = @employee.salary_histories.chronological
        render json: {
          salaries: salaries.map { |s| salary_history_json(s) }
        }
      end

      def create
        salary = @employee.salary_histories.build(salary_params)

        if salary.save
          render json: { salary: salary_history_json(salary) }, status: :created
        else
          render json: { errors: salary.errors.messages.transform_values(&:first) }, status: :unprocessable_entity
        end
      end

      private

      def set_employee
        @employee = Employee.find(params[:employee_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Employee not found" }, status: :not_found
      end

      def salary_params
        params.require(:salary).permit(:gross_salary, :effective_date, :reason, :notes)
      end

      def salary_history_json(salary)
        {
          id:             salary.id,
          gross_salary:   salary.gross_salary,
          effective_date: salary.effective_date,
          reason:         salary.reason,
          notes:          salary.notes,
          created_at:     salary.created_at
        }
      end
    end
  end
end
