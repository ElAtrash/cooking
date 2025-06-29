Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  resources :recipes do
    member do
      post :favorite
    end

    resources :recipe_ratings, only: [ :create, :update, :destroy ], shallow: true
    resources :recipe_ingredients, only: [ :create, :update, :destroy ], shallow: true
    resources :recipe_steps, only: [ :create, :update, :destroy ], shallow: true
  end

  get "/my_recipes", to: "recipes#index", defaults: { user: "mine" }
  get "/favorites", to: "favorite_recipes#index"

  root "recipes#index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
