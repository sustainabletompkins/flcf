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
      get 'detail'
    end
    collection do
      post 'change'
    end
  end
  
  resources :cart_items, :only => [:create, :destroy] do
    collection do
      post 'populate_cart'
    end
  end

  resources :individuals, :only => [:create, :update, :destroy] do
    collection do
      post 'add_to'
    end
  end

  resources :charges, :only => [:create, :new]

  resources :prizes, :only => [:create, :update, :destroy, :index]
  resources :prize_winners, :only => [:destroy, :create]
  resources :offsetters, :only => [:create, :update, :show, :destroy]
  resources :awardees, :only => [:create, :update, :show, :destroy]
  resources :pages,  :only => [:create, :update, :destroy]
  resources :message_templates, :only => [:update, :index]

  match '/users/:id/finish_signup' => 'users#finish_signup', via: [:get, :patch], :as => :finish_signup
  root :to => 'pages#index'
  match '/offset-log' => 'pages#offset_log', via: [:get]
  match '/calculator' => 'pages#calculator', via: [:get]
  get 'pages/:page_name' => 'pages#index'
  post 'offsets/add_name_and_zip/' => 'offsets#add_name_and_zip', :as => :add_user_data
  get '/awardees/video/:id' => 'awardees#show_video', :as => :awardee_video
  get '/calc-admin' => 'pages#admin', :as => :admin_path
  get 'log-spin' => 'prizes#log', :as => :log_spin
  post '/offsets/make-donation' => 'offsets#save_donation', :as => :save_donation

  get 'test', to: 'pages#js_test'
  get '/error', to: 'pages#card_error'
  get '/calculator', to: 'pages#calculator'
  get '/charges/success', to: 'charges#success'
  get '/charges/subscribe', to: 'charges#subscribe'
  get '/checkout-session', to: 'charges#get_session'
  get '/payment-success', to: 'pages#payment_success'
  get '/init-checkout-session', to: 'charges#init_checkout'
  post '/customer-portal', to: 'charges#manage'
  get '.well-known/pki-validation/:filename' => 'pages#verification'
  # Error page route
  get 'processing-error', to: 'pages#processing_error'
  get 'exports/awardees', to: 'awardees#csv'
  get 'exports/offsetters', to: 'offsetters#csv'

end
