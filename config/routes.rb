Rails.application.routes.draw do
  root to: 'main#index'
  get '*path' => 'main#index'
  # Omniauth
  get '/auth/:provider/callback', to: 'sessions#create'
end
