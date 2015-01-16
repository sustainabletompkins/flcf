Rails.application.routes.draw do
  devise_for :users,
    :controllers => { :sessions => "sessions" }


  resources :offsets, :only => [:create,:destroy,:show] do
    collection do
      get 'process_purchased'
      post 'duplicate'
      post 'populate_cart'
    end
  end
  root :to => 'pages#home'
  get 'pages/:page_name' => 'pages#index', :as => :pages
end
