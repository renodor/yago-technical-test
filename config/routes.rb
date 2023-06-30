# frozen_string_literal:true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'leads#new'

  resources :leads, only: %i[new create] do
    resources :quotes, only: %i[new create]
  end

  resources :quotes, only: :show
end
