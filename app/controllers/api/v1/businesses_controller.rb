# app/controllers/api/v1/businesses_controller.rb
class Api::V1::BusinessesController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:index, :show, :search, :nearby, :featured]
  before_action :set_business, only: [:show, :update, :destroy, :approve, :reject, :suspend, :feature, :unfeature, :analytics]
  before_action :ensure_owner_or_admin, only: [:update, :destroy, :analytics]
  before_action :ensure_admin!, only: [:approve, :reject, :suspend, :feature, :unfeature]

  def index
    @businesses = Business.approved
                         .includes(:user, :business_categories, :reviews)
                         .by_membership_priority

    @businesses = apply_filters(@businesses)
    @businesses = paginate_collection(@businesses)

    render json: {
      success: true,
      data: {
        businesses: @businesses.map { |business| business_summary_data(business) },
        meta: pagination_meta(@businesses)
      }
    }
  end

  def show
    render json: {
      success: true,
      data: {
        business: detailed_business_data(@business)
      }
    }
  end

  def create
    ensure_business_owner!
    
    @business = current_user.build_business(business_params)

    if @business.save
      render json: {
        success: true,
        message: 'Business created successfully',
        data: {
          business: detailed_business_data(@business)
        }
      }, status: :created
    else
      render json: {
        success: false,
        message: 'Business creation failed',
        errors: @business.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @business.update(business_params)
      render json: {
        success: true,
        message: 'Business updated successfully',
        data: {
          business: detailed_business_data(@business)
        }
      }
    else
      render json: {
        success: false,
        message: 'Business update failed',
        errors: @business.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @business.destroy
    render json: {
      success: true,
      message: 'Business deleted successfully'
    }
  end

  def search
    @businesses = Business.approved
                         .includes(:user, :business_categories, :reviews)
    
    if params[:q].present?
      @businesses = @businesses.where(
        "business_name ILIKE ? OR description ILIKE ? OR areas_served ILIKE ?",
        "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%"
      )
    end

    @businesses = apply_filters(@businesses)
    @businesses = paginate_collection(@businesses)

    render json: {
      success: true,
      data: {
        businesses: @businesses.map { |business| business_summary_data(business) },
        meta: pagination_meta(@businesses)
      }
    }
  end

  def nearby
    lat = params[:latitude]&.to_f
    lng = params[:longitude]&.to_f
    radius = params[:radius]&.to_i || 25

    if lat && lng
      @businesses = Business.approved
                           .includes(:user, :business_categories, :reviews)
                           .where.not(latitude: nil, longitude: nil)
      
      # Simple distance calculation (you'd want to use PostGIS in production)
      @businesses = @businesses.select do |business|
        business.distance_from(lat, lng) <= radius if business.latitude && business.longitude
      end

      @businesses = @businesses.sort_by { |business| business.distance_from(lat, lng) }
      
      render json: {
        success: true,
        data: {
          businesses: @businesses.map { |business| 
            data = business_summary_data(business)
            data[:distance] = business.distance_from(lat, lng)
            data
          }
        }
      }
    else
      render json: {
        success: false,
        message: 'Latitude and longitude are required'
      }, status: :bad_request
    end
  end

  def featured
    @businesses = Business.approved
                         .featured
                         .includes(:user, :business_categories, :reviews)
                         .by_membership_priority

    @businesses = paginate_collection(@businesses)

    render json: {
      success: true,
      data: {
        businesses: @businesses.map { |business| business_summary_data(business) },
        meta: pagination_meta(@businesses)
      }
    }
  end

  def approve
    @business.update!(business_status: :approved)
    render json: {
      success: true,
      message: 'Business approved successfully'
    }
  end

  def reject
    @business.update!(business_status: :rejected)
    render json: {
      success: true,
      message: 'Business rejected'
    }
  end

  def suspend
    @business.update!(business_status: :suspended)
    render json: {
      success: true,
      message: 'Business suspended'
    }
  end

  def feature
    @business.update!(featured: true)
    render json: {
      success: true,
      message: 'Business featured successfully'
    }
  end

  def unfeature
    @business.update!(featured: false)
    render json: {
      success: true,
      message: 'Business unfeatured'
    }
  end

  def analytics
    render json: {
      success: true,
      data: {
        analytics: business_analytics_data(@business)
      }
    }
  end

  private

  def set_business
    @business = Business.find_by!(slug: params[:id]) || Business.find(params[:id])
  end

  def ensure_owner_or_admin
    unless @business.user == current_user || current_user.admin?
      render json: {
        success: false,
        message: 'Access denied'
      }, status: :forbidden
    end
  end

  def business_params
    params.require(:business).permit(
      :business_name, :description, :business_phone, :business_email,
      :license_number, :areas_served, :website_url,
      :address_line1, :address_line2, :city, :state, :zip_code,
      :meta_title, :meta_description,
      business_category_ids: [], images: [], documents: []
    )
  end

  def apply_filters(businesses)
    businesses = businesses.joins(:business_categories).where(business_categories: { id: params[:category_ids] }) if params[:category_ids].present?
    businesses = businesses.where(state: params[:state]) if params[:state].present?
    businesses = businesses.where(city: params[:city]) if params[:city].present?
    businesses = businesses.joins(:user).where(users: { membership_status: params[:membership_status] }) if params[:membership_status].present?
    businesses = businesses.featured if params[:featured] == 'true'
    businesses = businesses.verified if params[:verified] == 'true'
    
    businesses
  end

  def business_summary_data(business)
    {
      id: business.id,
      business_name: business.business_name,
      slug: business.slug,
      description: business.description&.truncate(150),
      business_phone: business.business_phone,
      business_email: business.business_email,
      website_url: business.website_url,
      full_address: business.full_address,
      average_rating: business.average_rating,
      total_reviews: business.total_reviews,
      featured: business.featured?,
      verified: business.verified?,
      military_owned: business.military_owned?,
      business_status: business.business_status,
      # Fixed Active Storage issue - safe check for attached images
      primary_image: (business.images.attached? && business.images.any?) ? url_for(business.images.first) : nil,
      owner: {
        name: business.user.full_name,
        membership_status: business.user.membership_status
      },
      categories: business.business_categories.active.map(&:name),
      created_at: business.created_at
    }
  end

  def detailed_business_data(business)
    data = business_summary_data(business)
    data.merge!({
      license_number: business.license_number,
      areas_served: business.areas_served,
      address_line1: business.address_line1,
      address_line2: business.address_line2,
      city: business.city,
      state: business.state,
      zip_code: business.zip_code,
      latitude: business.latitude,
      longitude: business.longitude,
      business_hours: business.business_hours,
      meta_title: business.meta_title,
      meta_description: business.meta_description,
      # Fixed Active Storage issue - safe check for attached files
      images: business.images.attached? ? business.images.map { |img| url_for(img) } : [],
      documents: business.documents.attached? ? business.documents.map { |doc| { name: doc.filename, url: url_for(doc) } } : [],
      owner_details: {
        id: business.user.id,
        full_name: business.user.full_name,
        email: business.user.email,
        phone: business.user.phone,
        membership_status: business.user.membership_status,
        military_verified: business.user.military_verified?
      },
      real_estate_agent: business.real_estate_agent ? real_estate_agent_data(business.real_estate_agent) : nil,
      recent_reviews: business.reviews.active.recent.limit(5).map { |review| review_data(review) },
      updated_at: business.updated_at
    })
  end

  def real_estate_agent_data(agent)
    {
      id: agent.id,
      brokerage_name: agent.brokerage_name,
      broker_email: agent.broker_email,
      brokerage_phone: agent.brokerage_phone,
      brokerage_license_number: agent.brokerage_license_number,
      specialties: agent.specialties,
      certifications: agent.certifications
    }
  end

  def review_data(review)
    {
      id: review.id,
      rating: review.rating,
      review_title: review.review_title,
      review_text: review.review_text,
      verified: review.verified?,
      reviewer_name: review.user.full_name,
      created_at: review.created_at
    }
  end

  def business_analytics_data(business)
    {
      total_views: 0, # Implement view tracking
      total_inquiries: business.inquiries.count,
      total_reviews: business.total_reviews,
      average_rating: business.average_rating,
      inquiries_this_month: business.inquiries.where(created_at: 1.month.ago..Time.current).count,
      reviews_this_month: business.reviews.where(created_at: 1.month.ago..Time.current).count
    }
  end
end