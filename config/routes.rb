Rails.application.routes.draw do
  devise_for :users


  resources :offsets, :only => [:create,:delete,:show]
  root :to => 'pages#home'
  get 'pages/:page_name' => 'pages#index', :as => :pages
end
