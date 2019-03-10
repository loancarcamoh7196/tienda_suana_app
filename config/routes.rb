Rails.application.routes.draw do
  resources :addresses
  resources :authors
  resources :banners 
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users
  resources :profiles, only: [:index] do
    collection do
      get 'address', to: 'profiles#address', as: 'address'
    end
  end

  resources :deliveries
  resources :brands, only: %i[index new create edit update destroy]
  resources :categories
  resources :suggestions, only: %i[index new create edit upgrade]
  resources :products do
    resources :details, only: %i[create destroy edit update]
  end
  
  resources :details, only: %i[index show] do
    resource :orders, only: :create
    resource :wishlist, only: %i[create destroy]
    resources :comments, only: %i[new create edit update destroy]
    collection do
      get 'view_for_category/:name', to: 'details#view_for_category', as: 'search_category'
      get 'list_gift', to: 'details#list_gift', as: 'list_gift'
    end
  end
  resources :comments, only: :index do
    post 'banned', to: 'comments#banned'
  end
  resources :clusters, only: %i[show]
  resources :wishlists, only: :index

  resources :orders, only: [:destroy] do
    patch 'remove_one_item'
    collection do
      get 'cart'
      delete 'empty_cart'
      post 'buy'
    end
  end

  resources :billings, only: [] do
    collection do
      post 'pre_pay'
      get 'execute'
    end
  end
  get 'bought_products', to: 'orders#bought_products', as: 'bought_products'
  get 'pages/index'
  get 'pages/home'
  get 'pages/contact'
  get 'pages/us'
  

  root 'details#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
