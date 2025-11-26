Rails.application.routes.draw do
  resources :trips, only: [:index, :new, :create, :show] do
    member do
      get 'join'
      post 'accept_invitation'
    end
    resource :trip_invitations, only: [:new, :create]
    resource :preferences_form, only: [:new, :create]
    resources :recommendations, only: [:create, :show]
    resources :itineraries, only: [:create, :show]
  end
  resources :recommendation_items, only: [] do
    resources :votes, only: [:create]
  end
  devise_for :users
  root to: 'pages#home'

  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Silence Chrome DevTools error
  get "/.well-known/appspecific/com.chrome.devtools.json", to: proc { [404, {}, ['']] }
end
