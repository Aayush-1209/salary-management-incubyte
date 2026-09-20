module Api
  module Analytics
    class SummaryController < ApplicationController
      def show
        # Only active employees
        active_employees = Employee.active.includes(:salary_histories)

        departments = active_employees.group_by(&:department)

        department_stats = departments.map do |dept_name, employees|
          # Further group by currency since departments might span countries
          employees.group_by(&:currency).map do |currency, cur_employees|
            total_salary = cur_employees.sum do |e|
              current = e.salary_histories.max_by(&:effective_date)
              current ? current.gross_salary : 0
            end

            {
              name: dept_name,
              employee_count: cur_employees.size,
              total_salary: total_salary,
              currency: currency
            }
          end
        end.flatten

        total_employees = active_employees.size
        total_departments = departments.keys.size

        render json: {
          summary: {
            total_employees: total_employees,
            total_departments: total_departments,
            departments: department_stats
          }
        }
      end
    end
  end
end
