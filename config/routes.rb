Rails.application.routes.draw do
  root to: 'main#index'

  # Omniauth
  get '/auth/:provider/callback', to: 'sessions#create'

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :repos, only: [:index, :create, :show, :destroy]
      resources :builds, only: :index
      resource :user_session, only: [:show, :destroy]

      # alias for repos/show
      get '/:user/:repo', to: 'repos#show'
    end
  end

  resources :builds, only: :create

  # we could put other status code here too
  %w(422 500).each do |status_code|
    get status_code, to: "errors#show", code: status_code
  end

  get '*path' => 'main#index'
end
