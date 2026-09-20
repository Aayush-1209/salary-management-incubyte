Rails.application.routes.draw do
  root to: ->(_) { [200, { 'Content-Type' => 'application/json' }, [{ status: 'ok', message: 'Salary Management API is running' }.to_json]] }

  namespace :api do
    get "health", to: "health#show"

    resources :employees, only: %i[index show] do
      resources :salaries, only: %i[index create], module: :employees
    end

    namespace :analytics do
      get "summary", to: "summary#show"
    end
  end
end
