Rails.application.routes.draw do
  root :to => 'pages#home'
  get 'pages/:page_name' => 'pages#index', :as => :pages
end
