Rails.application.routes.draw do
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
