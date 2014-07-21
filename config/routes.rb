Rails.application.routes.draw do
  
  root to: 'sessions#index'
  
  get "sign_up" => 'users#new', as: "sign_up"
  
  get "log_in" => 'sessions#new', as: 'log_in' 
  
  get "log_out" => 'sessions#destroy', as: 'log_out' 
  
  get 'userinfo' => "users#userinfo" 
  
  resources :users
  
  resources :sessions
  
  resources :clients
  
  resources :authorise
  
  resources :token

end
