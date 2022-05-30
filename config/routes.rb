Rails.application.routes.draw do
  resources :admins
  use_doorkeeper do
    skip_controllers :authorizations, :applications, :authorized_applications
  end
  devise_for :users

  resources :accounts
  resources :photos

  root 'accounts#show'
end
