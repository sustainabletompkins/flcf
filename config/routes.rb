Rails.application.routes.draw do
  devise_for :users


  resources :offsets, :only => [:create,:destroy,:show] do
    collection do
      get 'process_purchased'
    end
  end
  root :to => 'pages#home'
  get 'pages/:page_name' => 'pages#index', :as => :pages
end
