module Api
  class HealthController < ApplicationController
    def show
      render json: {
        status: "ok",
        timestamp: Time.current.utc.iso8601,
        database: database_status,
        employee_count: employee_count
      }
    end

    private

    def database_status
      ActiveRecord::Base.connection.execute("SELECT 1")
      "connected"
    rescue StandardError
      "disconnected"
    end

    def employee_count
      Employee.count
    rescue StandardError
      nil
    end
  end
end
