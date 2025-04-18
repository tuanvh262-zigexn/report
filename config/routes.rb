require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check
  namespace :apw do
    root "entries#index"
    get 'timecrowds', to: 'timecrowds#index'
    resources :reports, only: :index
    resources :stories, only: :show
    namespace :ajax do
      resources :stories, only: :index
    end

    mount Sidekiq::Web, at: '/sidekiq'
  end
end
