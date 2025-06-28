# config/routes.rb
Rails.application.routes.draw do
  devise_for :users, skip: :all  

  namespace :api do
    namespace :v1 do
      # Authentication routes
      namespace :auth do
        post 'login'
        post 'register'
        get 'me'
        delete 'logout'
        post 'forgot_password'
        post 'reset_password'
      end

      # User routes
      resources :users, only: [:show, :update] do
        resource :military_background, only: [:show, :create, :update, :destroy]
      end

      # Business routes
      resources :businesses do
        resources :reviews, only: [:index, :create, :update, :destroy]
        resources :inquiries, only: [:index, :create, :show, :update]
        resource :real_estate_agent, only: [:show, :create, :update, :destroy]
        
        member do
          patch :approve
          patch :reject
          patch :suspend
          patch :feature
          patch :unfeature
          get :analytics
        end

        collection do
          get :search
          get :nearby
          get :featured
        end
      end

      # Business categories
      resources :business_categories, only: [:index, :show] do
        member do
          get :businesses
        end
      end

      # Admin routes
      namespace :admin do
        resources :users do
          member do
            patch :activate
            patch :deactivate
            patch :verify_military
          end
        end
        
        resources :businesses do
          member do
            patch :approve
            patch :reject
            patch :suspend
            patch :feature
            patch :verify
          end
        end
        
        resources :business_categories
        resources :reviews, only: [:index, :show, :update, :destroy]
        
        get 'dashboard', to: 'dashboard#index'
        get 'analytics', to: 'dashboard#analytics'
      end
    end
  end

  # Health check
  get 'health', to: 'health#check'
end