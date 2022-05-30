Rails.application.routes.draw do
  resources :admins
  use_doorkeeper do
    skip_controllers :authorizations, :applications, :authorized_applications
  end
  devise_for :users
  devise_scope :user do
		get '/logout', to: 'devise/sessions#destroy', as: 'logout'
	end
	post '/users/photos', to: 'accounts#update_profile_picture', as: 'update_profile_picture'

  resources :accounts
  resources :photos

  root 'accounts#show'
end
