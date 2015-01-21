Rails.application.routes.draw do
  devise_for :users,
    :controllers => { :sessions => "sessions" },
    :controllers => { omniauth_callbacks: 'omniauth_callbacks' }


  resources :offsets, :only => [:create,:destroy,:show] do
    collection do
      get 'process_purchased'
      post 'duplicate'
      post 'populate_cart'
    end
  end

  match '/users/:id/finish_signup' => 'users#finish_signup', via: [:get, :patch], :as => :finish_signup
  root :to => 'pages#home'
  get 'pages/:page_name' => 'pages#index', :as => :pages
end
