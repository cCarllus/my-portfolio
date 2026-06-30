Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
  resource :portfolio_request, only: :create

  namespace :admin do
    resource :session, only: %i[new create destroy]
    root "dashboard#index"

    resource :profile, only: %i[edit update]
    resource :email_template, only: %i[edit update]
    resource :map, only: %i[edit update]
    resource :database, only: :show do
      get :export_sql
      get :export_sqlite
      post :import
    end
    resources :skills do
      patch :reorder, on: :collection
    end
    resources :experiences do
      patch :reorder, on: :collection
    end
    resources :highlights do
      patch :reorder, on: :collection
      post :sync_github, on: :collection
    end
    resources :educations do
      patch :reorder, on: :collection
    end
    resources :portfolio_documents do
      patch :reorder, on: :collection
    end
    resources :contact_requests, only: %i[index show]
  end
end
