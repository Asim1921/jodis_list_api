# app/controllers/api/v1/businesses_controller.rb - Final Fixed Version
class Api::V1::BusinessesController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:index, :show, :search, :nearby, :featured]
  before_action :set_business, only: [:show]

  # GET /api/v1/businesses
  def index
    @businesses = Business.approved
                         .includes(:user, :business_categories, :reviews)
                         .by_membership_priority

    @businesses = apply_advanced_filters(@businesses)
    @businesses = apply_sorting(@businesses)
    @businesses = paginate_collection(@businesses)

    render json: {
      success: true,
      data: {
        businesses: @businesses.map { |business| business_summary_data(business) },
        meta: pagination_meta(@businesses),
        filters: available_filters
      }
    }
  end

  # GET /api/v1/businesses/:id
  def show
    render json: {
      success: true,
      data: {
        business: detailed_business_data(@business)
      }
    }
  end

  # GET /api/v1/businesses/search
  def search
    @businesses = Business.approved.includes(:user, :business_categories, :reviews)
    
    # Keyword search - FIXED: Specify table name to avoid ambiguous column
    if params[:q].present?
      keyword = "%#{params[:q].strip}%"
      @businesses = @businesses.where(
        "businesses.business_name ILIKE ? OR businesses.description ILIKE ? OR businesses.areas_served ILIKE ?",
        keyword, keyword, keyword
      )
    end

    # Advanced filters
    @businesses = apply_advanced_filters(@businesses)
    @businesses = apply_sorting(@businesses)
    @businesses = paginate_collection(@businesses)

    render json: {
      success: true,
      data: {
        businesses: @businesses.map { |business| business_summary_data(business) },
        meta: pagination_meta(@businesses),
        search_params: search_params_summary
      }
    }
  end

  # GET /api/v1/businesses/nearby
  def nearby
    lat = params[:latitude]&.to_f
    lng = params[:longitude]&.to_f
    radius = params[:radius]&.to_i || 25

    if lat && lng
      @businesses = Business.approved
                           .includes(:user, :business_categories, :reviews)
                           .where.not(latitude: nil, longitude: nil)
                           .nearby(lat, lng, radius)
      
      # Calculate distances and add to results
      businesses_with_distance = @businesses.map do |business|
        distance = business.distance_from(lat, lng)
        business.define_singleton_method(:calculated_distance) { distance }
        business
      end.sort_by(&:calculated_distance)

      # FIXED: Use simple pagination for arrays
      @businesses = simple_paginate_array(businesses_with_distance)
      
      render json: {
        success: true,
        data: {
          businesses: @businesses[:items].map { |business| 
            data = business_summary_data(business)
            data[:distance] = business.calculated_distance if business.respond_to?(:calculated_distance)
            data
          },
          meta: @businesses[:meta],
          search_center: { latitude: lat, longitude: lng, radius: radius }
        }
      }
    else
      render json: {
        success: false,
        message: 'Latitude and longitude are required for nearby search'
      }, status: :bad_request
    end
  end

  # GET /api/v1/businesses/featured
  def featured
    @businesses = Business.approved
                         .featured
                         .includes(:user, :business_categories, :reviews)
                         .by_membership_priority

    @businesses = apply_advanced_filters(@businesses)
    @businesses = apply_sorting(@businesses)
    @businesses = paginate_collection(@businesses)

    render json: {
      success: true,
      data: {
        businesses: @businesses.map { |business| business_summary_data(business) },
        meta: pagination_meta(@businesses)
      }
    }
  end

  private

  def set_business
    @business = Business.find_by(slug: params[:id]) || Business.find(params[:id])
  end

  def apply_advanced_filters(businesses)
    # Category filter
    if params[:category_ids].present?
      category_ids = params[:category_ids].is_a?(Array) ? params[:category_ids] : [params[:category_ids]]
      businesses = businesses.joins(:business_categories).where(business_categories: { id: category_ids })
    end
    
    # Location filters
    businesses = businesses.where("businesses.state ILIKE ?", "%#{params[:state]}%") if params[:state].present?
    businesses = businesses.where("businesses.city ILIKE ?", "%#{params[:city]}%") if params[:city].present?
    
    # Service filters
    businesses = businesses.where(verified: true) if params[:verified] == 'true'
    businesses = businesses.where(featured: true) if params[:featured] == 'true'
    businesses = businesses.where(emergency_service: true) if params[:emergency_service] == 'true'
    businesses = businesses.where(insured: true) if params[:insured] == 'true'
    
    # Military owned filter
    if params[:military_owned] == 'true'
      businesses = businesses.joins(:user)
                            .joins('LEFT JOIN military_backgrounds ON military_backgrounds.user_id = users.id')
                            .where('users.membership_status = ? OR military_backgrounds.verified = ?', 'veteran', true)
    end
    
    # Rating filter
    if params[:min_rating].present?
      min_rating = params[:min_rating].to_f
      businesses = businesses.joins(:reviews)
                            .group('businesses.id')
                            .having('AVG(reviews.rating) >= ?', min_rating)
    end
    
    businesses
  end

  def apply_sorting(businesses)
    case params[:sort_by]
    when 'rating'
      businesses.joins(:reviews).group('businesses.id').order('AVG(reviews.rating) DESC')
    when 'newest'
      businesses.order(created_at: :desc)
    when 'name'
      businesses.order(:business_name)
    when 'membership'
      businesses.by_membership_priority
    else
      businesses.by_membership_priority
    end
  end

  def available_filters
    {
      categories: BusinessCategory.active.ordered.pluck(:id, :name),
      states: Business.approved.distinct.pluck(:state).compact.sort,
      cities: Business.approved.distinct.pluck(:city).compact.sort,
      rating_options: [
        { value: 4.5, label: '4.5+ Stars' },
        { value: 4.0, label: '4.0+ Stars' },
        { value: 3.5, label: '3.5+ Stars' },
        { value: 3.0, label: '3.0+ Stars' }
      ],
      sort_options: [
        { value: 'relevance', label: 'Most Relevant' },
        { value: 'rating', label: 'Highest Rated' },
        { value: 'newest', label: 'Newest' },
        { value: 'name', label: 'Name A-Z' },
        { value: 'membership', label: 'Military Priority' }
      ]
    }
  end

  def search_params_summary
    {
      keyword: params[:q],
      categories: params[:category_ids],
      location: {
        state: params[:state],
        city: params[:city],
        coordinates: params[:latitude] && params[:longitude] ? 
          { lat: params[:latitude], lng: params[:longitude] } : nil,
        radius: params[:radius]
      },
      filters: {
        verified: params[:verified],
        featured: params[:featured],
        emergency_service: params[:emergency_service],
        insured: params[:insured],
        military_owned: params[:military_owned],
        min_rating: params[:min_rating]
      },
      sort: params[:sort_by]
    }
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
      city: business.city,
      state: business.state,
      average_rating: business.average_rating,
      total_reviews: business.total_reviews,
      featured: business.featured?,
      verified: business.verified?,
      military_owned: business.military_owned?,
      business_status: business.business_status,
      emergency_service: business.emergency_service?,
      insured: business.insured?,
      owner: {
        name: business.user.full_name,
        membership_status: business.user.membership_status
      },
      categories: business.business_categories.map { |cat|
        { id: cat.id, name: cat.name, icon_class: cat.icon_class }
      },
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
      zip_code: business.zip_code,
      latitude: business.latitude,
      longitude: business.longitude,
      business_hours: business.business_hours,
      years_in_business: business.years_in_business,
      employee_count: business.employee_count,
      bonded: business.bonded?,
      background_checked: business.background_checked?,
      meta_title: business.meta_title,
      meta_description: business.meta_description,
      owner_details: {
        id: business.user.id,
        full_name: business.user.full_name,
        email: business.user.email,
        phone: business.user.phone,
        membership_status: business.user.membership_status,
        military_verified: business.user.military_background&.verified? || false
      },
      updated_at: business.updated_at
    })
  end

  # FIXED: Simple pagination for ActiveRecord collections
  def paginate_collection(collection)
    page = params[:page]&.to_i || 1
    per_page = params[:per_page]&.to_i || 20
    per_page = [per_page, 100].min # Limit max per page
    
    if collection.respond_to?(:page)
      # Use Kaminari if available
      collection.page(page).per(per_page)
    else
      # Fallback pagination
      collection.limit(per_page).offset((page - 1) * per_page)
    end
  end

  # FIXED: Simple array pagination without OpenStruct
  def simple_paginate_array(array)
    page = params[:page]&.to_i || 1
    per_page = params[:per_page]&.to_i || 20
    per_page = [per_page, 100].min
    
    total = array.size
    offset = (page - 1) * per_page
    items = array[offset, per_page] || []
    
    {
      items: items,
      meta: {
        current_page: page,
        per_page: per_page,
        total_count: total,
        total_pages: (total.to_f / per_page).ceil
      }
    }
  end

  # FIXED: Pagination metadata helper
  def pagination_meta(collection)
    if collection.respond_to?(:current_page)
      # Kaminari pagination
      {
        current_page: collection.current_page,
        per_page: collection.limit_value,
        total_count: collection.total_count,
        total_pages: collection.total_pages
      }
    else
      # Simple pagination
      page = params[:page]&.to_i || 1
      per_page = params[:per_page]&.to_i || 20
      total = collection.count
      
      {
        current_page: page,
        per_page: per_page,
        total_count: total,
        total_pages: (total.to_f / per_page).ceil
      }
    end
  end
end