Rails.application.routes.draw do
  root to: 'main#index'
  get '*path' => 'main#index'
end
