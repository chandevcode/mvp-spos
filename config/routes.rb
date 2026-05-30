Rails.application.routes.draw do
  get "dashboard", to: "dashboard#index", as: :dashboard
  
  devise_for :users
  resources :products
  resources :users, only: [:index, :new, :create, :destroy]
  resources :transactions, only: [:show]

  post "cart/add/:product_id", to: "cart#add", as: :add_to_cart
  post "cart/remove/:product_id", to: "cart#remove", as: :remove_from_cart
  delete "cart/clear", to: "cart#clear", as: :clear_cart
  get "cart", to: "cart#show", as: :cart
  post "cart/checkout", to: "cart#checkout", as: :checkout

  root "home#index"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
