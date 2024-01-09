require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  # Existing route from the old code
  post '/api/users/login' => 'api/users#login'

  # Consolidated routes from new and existing code
  namespace :api do
    post '/users/register', to: 'users#register' # This route is declared in both new and existing code, so we keep it once
    post '/users/:id/link-social', to: 'users#link_social_account' # This is from the new code
    put '/users/change-password', to: 'users#change_password' # This route is declared in both new and existing code, so we keep it once
  end

  # ... other routes ...
end
