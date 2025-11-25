Rails.application.routes.draw do
  resources :trips, only: [:new, :create, :show] do
    post 'join', on: :member
    resources :trip_invitations, only: [:new, :create]
    resources :preferences_forms, only: [:new, :create]
    resources :recommendations, only: [:create, :show]
    resources :itineraries, only: [:create, :show]
  end
  resources :recommendation_items, only: [] do
    resources :votes, only: [:create]
  end
  devise_for :users
  root to: 'pages#home'

  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
