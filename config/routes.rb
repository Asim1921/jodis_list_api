# config/routes.rb - Enhanced for Module 2
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

      # Enhanced Business routes for Module 2
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
          post :upload_documents
          delete :remove_document
        end

        collection do
          # Enhanced search endpoints
          get :search
          get :advanced_search
          get :nearby
          get :featured
          get :apply # GET form for application
          post :apply # POST to submit application
          get :filters # Get available filter options
          
          # Map-based endpoints
          get :map_data
          get :service_areas
          
          # Analytics endpoints
          get :trending
          get :popular_categories
          get :statistics
        end
      end

      # Business categories with enhanced endpoints
      resources :business_categories, only: [:index, :show] do
        member do
          get :businesses
          get :statistics
        end
        
        collection do
          get :tree # Hierarchical category structure
          get :popular # Most popular categories
        end
      end

      # Search and Discovery endpoints
      namespace :search do
        get :businesses
        get :autocomplete
        get :suggestions
        post :save_search # Save search for notifications
        get :saved_searches
        delete :saved_searches
      end

      # Geolocation services
      namespace :geo do
        get :states
        get :cities
        get :zip_codes
        post :geocode
        post :reverse_geocode
        get :service_areas
      end

      # File upload endpoints
      namespace :uploads do
        post :business_images
        post :business_documents
        post :certifications
        delete :remove_file
      end

      # Review aggregation endpoints
      namespace :reviews do
        get :aggregate # Aggregate reviews from external sources
        post :import_external
        get :external_sources
      end

      # Admin routes with enhanced business management
      namespace :admin do
        resources :users do
          member do
            patch :activate
            patch :deactivate
            patch :verify_military
            get :business_applications
          end
        end
        
        resources :businesses do
          member do
            patch :approve
            patch :reject
            patch :suspend
            patch :feature
            patch :verify
            get :review_application
            post :request_documents
            get :verification_status
          end
          
          collection do
            get :pending_approval
            get :bulk_actions
            post :bulk_approve
            post :bulk_reject
            get :verification_queue
          end
        end
        
        resources :business_categories do
          member do
            patch :activate
            patch :deactivate
            post :reorder
          end
        end
        
        resources :reviews, only: [:index, :show, :update, :destroy] do
          member do
            patch :approve
            patch :flag
          end
        end
        
        # Admin dashboard and analytics
        get 'dashboard', to: 'dashboard#index'
        get 'analytics', to: 'dashboard#analytics'
        get 'reports', to: 'dashboard#reports'
        
        # Business application management
        namespace :applications do
          get :pending
          get :under_review
          get :approved
          get :rejected
          post :batch_process
        end
        
        # Data management
        namespace :data do
          post :import_businesses
          get :export_businesses
          post :scrape_veteran_directory
          get :scraping_status
        end
      end

      # Public API endpoints (no authentication required)
      namespace :public do
        get 'businesses/featured'
        get 'businesses/categories'
        get 'businesses/search'
        get 'statistics'
        get 'service_areas'
      end

      # Webhook endpoints for external integrations
      namespace :webhooks do
        post :google_reviews
        post :yelp_reviews
        post :facebook_reviews
        post :payment_confirmed
      end

      # Integration endpoints
      namespace :integrations do
        # Google Maps integration
        namespace :google do
          get :places_autocomplete
          get :place_details
          post :geocode
        end
        
        # External review platforms
        namespace :reviews do
          get :google_business_profile
          get :yelp_business
          get :facebook_page
        end
        
        # Marketing integrations
        namespace :marketing do
          post :mailchimp_sync
          post :social_media_post
        end
      end
    end
  end

  # Health check
  get 'health', to: 'health#check'
  
  # Sitemap for SEO
  get 'sitemap.xml', to: 'sitemap#index', defaults: { format: 'xml' }
  
  # Root route
  root 'health#check'
end