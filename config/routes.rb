Rails.application.routes.draw do
  devise_for :users, skip: [ :registrations ]
  get "dashboard", to: "dashboard#index", as: :dashboard

  resource :profile, only: [ :edit, :update ]

  # Extend subscription flow
  get "profile/extend", to: "subscriptions#extend_plan", as: :extend_subscription
  post "profile/extend", to: "subscriptions#create_extend"
  get "profile/extend/payment/:id", to: "subscriptions#extend_payment", as: :extend_subscription_payment
  get "profile/extend/payment_status/:id", to: "subscriptions#extend_payment_status", as: :extend_subscription_payment_status
  get "profile/extend/success", to: "subscriptions#extend_success", as: :extend_subscription_success

  resources :users, only: [ :index, :new, :create, :edit, :update, :destroy ]

  resources :products
  resources :transactions, only: [ :show, :update ]

  resources :inventory, only: [ :index ] do
    member do
      patch :update_stock
      patch :set_stock
    end
  end

  post "cart/add/:product_id", to: "cart#add", as: :add_to_cart
  post "cart/remove/:product_id", to: "cart#remove", as: :remove_from_cart
  delete "cart/clear", to: "cart#clear", as: :clear_cart
  get "cart", to: "cart#show", as: :cart
  post "cart/checkout", to: "cart#checkout", as: :checkout

  # Registration with subscription payment
  # IMPORTANT: static paths must come BEFORE the dynamic :plan route
  get "register", to: "registrations#choose_plan", as: :register
  post "register", to: "registrations#create"
  get "register/payment/:id", to: "registrations#payment", as: :register_payment
  get "register/payment_status/:id", to: "registrations#payment_status", as: :register_payment_status
  get "register/success", to: "registrations#success", as: :register_success
  get "register/check_email", to: "registrations#check_email", as: :register_check_email
  get "register/:plan", to: "registrations#new", as: :register_plan,
      constraints: { plan: /monthly|annual/ }

  # Midtrans webhook
  post "midtrans/webhook", to: "payment_webhooks#notification"

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
