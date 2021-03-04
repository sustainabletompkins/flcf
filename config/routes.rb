Rails.application.routes.draw do

  constraints CanAccessRailsAdmin do
    mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  end

  namespace :api do
    namespace :v1 do
      get 'calculator/air', to: 'offsets#air'
      get 'calculator/car', to: 'offsets#car'
      get 'calculator/home', to: 'offsets#home_energy'
      get 'calculator/quick', to: 'offsets#quick'
      get 'races/leaderboard', to: 'carbon_races#leaderboard'
      get 'races/team', to: 'carbon_races#team'
      get 'prizes/list', to: 'prizes#list'
      get 'prizes/winners', to: 'prizes#winners'
      get 'offsets/list', to: 'offsets#list'
      get 'offsets/summary', to: 'offsets#summary'
    end
  end

  devise_for :users,
    :controllers => { :registrations => "registrations", :sessions => "sessions",omniauth_callbacks: 'omniauth_callbacks' }


  resources :offsets, :only => [:create,:destroy,:show] do
    collection do
      get 'process_purchased'
      get 'filter'
      post 'duplicate'
      post 'add_name_and_zip'
      post 'manual_create'
    end
  end

  resources :teams, :only => [:update, :index, :show, :create] do
    member do
      post 'join'
      post 'change'
      get 'detail'
    end
  end
  
  resources :cart_items, :only => [:create, :destroy] do
    collection do
      post 'populate_cart'
    end
  end

  resources :individuals, :only => [:update, :destroy] do
    collection do
      post 'add_to'
    end
  end

  resources :charges, :only => [:create, :new]

  resources :prizes, :only => [:create, :update, :destroy, :index]
  resources :prize_winners, :only => [:destroy]
  resources :offsetters, :only => [:create, :update, :show, :destroy]
  resources :awardees, :only => [:create, :update, :show, :destroy]
  resources :pages,  :only => [:create, :update, :destroy]

  match '/users/:id/finish_signup' => 'users#finish_signup', via: [:get, :patch], :as => :finish_signup
  root :to => 'pages#home'
  match '/offset-log' => 'pages#offset_log', via: [:get]
  match '/calculator' => 'pages#calculator', via: [:get]
  get 'pages/:page_name' => 'pages#index'
  post 'offsets/add_name_and_zip/' => 'offsets#add_name_and_zip', :as => :add_user_data
  post '/save-prize' => 'prizes#save', :as => :prize_won
  get '/awardees/video/:id' => 'awardees#show_video', :as => :awardee_video
  get '/calc-admin' => 'pages#admin', :as => :admin_path
  get 'log-spin' => 'prizes#log', :as => :log_spin
  post '/offsets/make-donation' => 'offsets#save_donation', :as => :save_donation

  get '/error', to: 'pages#card_error'
  get '/calculator', to: 'pages#calculator'
  get '/charges/success', to: 'charges#success'
  get '/charges/subscribe', to: 'charges#subscribe'
  get '/checkout-session', to: 'charges#get_session'
  post '/customer-portal', to: 'charges#manage'
  get '.well-known/pki-validation/:filename' => 'pages#verification'


end
