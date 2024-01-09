require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  # Existing route from the old code
  post '/api/users/login' => 'api/users#login'

  # New route from the new code
  namespace :api do
    put '/users/change-password', to: 'users#change_password'
    post '/users/verify-email', to: 'users#verify_email'
  end

  # ... other routes ...
end
