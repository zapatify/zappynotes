Rails.application.routes.draw do
  get "account/show"
  get "account/update"
  mount Motor::Admin => "/motor_admin"
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Landing page
  root "pages#landing"

  # Authentication routes
  get "sign_in", to: "sessions#new"
  post "sign_in", to: "sessions#create"
  delete "sign_out", to: "sessions#destroy"

  get "sign_up", to: "registrations#new"
  post "sign_up", to: "registrations#create"

  # Main application
  get "app", to: "app#index", as: :app_root

  # Notebooks
  resources :notebooks, only: [ :create, :update, :destroy ] do
    member do
      patch :update_color
    end
    resources :notes, only: [ :create ], shallow: true
  end

  # Notes
  resources :notes, only: [ :show, :update, :destroy ]

  # Subscriptions
  resource :subscription, only: [ :show, :create ] do
    get :checkout_success
  end
  # Account settings
  get "account", to: "account#show"
  patch "account", to: "account#update"

  # Stripe webhooks
  post "webhooks/stripe", to: "webhooks#stripe"
end
