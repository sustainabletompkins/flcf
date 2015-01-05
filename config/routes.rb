Rails.application.routes.draw do
  devise_for :users
  root :to => 'pages#home'
  get 'pages/:page_name' => 'pages#index', :as => :pages
end
