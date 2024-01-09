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
    post '/users/register', to: 'users#register' # This route is duplicated and should be removed
    put '/users/change-password', to: 'users#change_password'
    put '/users/:id/profile', to: 'users#update_profile'
  end

  # ... other routes ...
end
