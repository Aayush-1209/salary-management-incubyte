module Api
  class EmployeesController < ApplicationController
    DEFAULT_PER_PAGE = 25
    MAX_PER_PAGE = 100

    def index
      employees = Employee.active
                          .then { |rel| apply_filters(rel) }
                          .then { |rel| apply_search(rel) }
                          .order(:last_name, :first_name)

      total = employees.count
      page     = [params[:page].to_i, 1].max
      per_page = per_page_param

      paginated = employees
                    .includes(:salary_histories)
                    .offset((page - 1) * per_page)
                    .limit(per_page)

      render json: {
        employees: paginated.map { |e| employee_summary(e) },
        meta: {
          total:       total,
          page:        page,
          per_page:    per_page,
          total_pages: (total.to_f / per_page).ceil
        }
      }
    end

    def show
      employee = Employee.includes(:salary_histories).find(params[:id])
      render json: { employee: employee_detail(employee) }
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Employee not found' }, status: :not_found
    end

    private

    def apply_filters(relation)
      relation = relation.by_country(params[:country])       if params[:country].present?
      relation = relation.by_department(params[:department]) if params[:department].present?
      relation = relation.by_currency(params[:currency])     if params[:currency].present?
      relation
    end

    def apply_search(relation)
      return relation if params[:search].blank?

      term = "%#{Employee.sanitize_sql_like(params[:search])}%"
      relation.where(
        'first_name ILIKE :term OR last_name ILIKE :term OR email ILIKE :term OR employee_number ILIKE :term',
        term: term
      )
    end

    def per_page_param
      requested = params[:per_page].to_i
      return DEFAULT_PER_PAGE unless requested.positive?

      requested.clamp(1, MAX_PER_PAGE)
    end

    def employee_summary(employee)
      current = employee.salary_histories.max_by(&:effective_date)
      {
        id:                   employee.id,
        employee_number:      employee.employee_number,
        email:                employee.email,
        first_name:           employee.first_name,
        last_name:            employee.last_name,
        full_name:            employee.full_name,
        country:              employee.country,
        department:           employee.department,
        job_title:            employee.job_title,
        level:                employee.level,
        currency:             employee.currency,
        hired_on:             employee.hired_on,
        active:               employee.active,
        current_gross_salary: current&.gross_salary
      }
    end

    def employee_detail(employee)
      employee_summary(employee).merge(
        salary_histories: employee.salary_histories
                                  .sort_by(&:effective_date)
                                  .reverse
                                  .map { |s| salary_history_json(s) }
      )
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
