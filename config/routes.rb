Rails.application.routes.draw do
  
  root to: 'sessions#index'
  
  get "sign_up" => 'users#new', as: "sign_up"
  
  get "log_in" => 'sessions#new', as: 'log_in' 
  
  get "logout" => 'sessions#destroy', as: 'log_out' 
  
  get 'userinfo' => "users#userinfo" 
  
  resources :users
  
  namespace :api do
    namespace :v1 do
      resources :users
      resources :clients
      put 'metadata' => "metadata#update"
    end
  end
  
  
  resources :sessions
  
  resources :clients
  
  resources :authorise
  
  resources :token

end
