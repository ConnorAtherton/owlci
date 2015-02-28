Rails.application.routes.draw do
  root to: 'main#index'

  # Omniauth
  get '/auth/:provider/callback', to: 'sessions#create'

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :repos, only: :index
      resource  :user_session, only: [:show, :destroy]
    end
  end

  get '*path' => 'main#index'
end
