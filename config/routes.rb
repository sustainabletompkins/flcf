Rails.application.routes.draw do
  devise_for :users,
    :controllers => { :sessions => "sessions" },
    :controllers => { omniauth_callbacks: 'omniauth_callbacks' }


  resources :offsets, :only => [:create,:destroy,:show] do
    collection do
      get 'process_purchased'
      post 'duplicate'
      post 'populate_cart'
      post 'add_name_and_zip'
    end
  end

  resources :charges

  match '/users/:id/finish_signup' => 'users#finish_signup', via: [:get, :patch], :as => :finish_signup
  root :to => 'pages#home'
  match '/offset-log' => 'pages#offset_log', via: [:get]
  get 'pages/:page_name' => 'pages#index', :as => :pages
end
