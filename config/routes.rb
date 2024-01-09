require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  post '/api/users/register', to: 'users#register'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  # Existing route from the old code
  post '/api/users/login' => 'api/users#login'

  # New route from the new code
  namespace :api do
    # The duplicated route for '/users/register' has been removed
    put '/users/change-password', to: 'users#change_password'
    put '/users/:id/profile', to: 'users#update_profile'
  end

  post '/api/users/social-register', to: 'api/users#social_register'

  # ... other routes ...
end
