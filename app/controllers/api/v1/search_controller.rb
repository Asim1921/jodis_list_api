class Api::V1::SearchController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:businesses, :autocomplete, :suggestions]
  
  # GET /api/v1/search/businesses
  def businesses
    search_service = BusinessSearchService.new(search_params)
    result = search_service.search
    
    render json: {
      success: true,
      data: {
        businesses: result[:businesses].map { |business| business_summary_data(business) },
        pagination: {
          current_page: result[:current_page],
          total_pages: result[:total_pages],
          total_count: result[:total_count],
          per_page: search_params[:per_page] || 20
        },
        search_metadata: result[:search_metadata],
        filters: available_filters
      }
    }
  end
  
  # GET /api/v1/search/autocomplete
  def autocomplete
    query = params[:q]
    location = params[:location]
    
    suggestions = []
    
    if query.present?
      # Business name suggestions
      business_suggestions = Business.approved
                                   .where("business_name ILIKE ?", "#{query}%")
                                   .limit(5)
                                   .pluck(:business_name, :city, :state)
                                   .map { |name, city, state| 
                                     {
                                       type: 'business',
                                       text: name,
                                       subtitle: "#{city}, #{state}",
                                       value: name
                                     }
                                   }
      
      # Category suggestions
      category_suggestions = BusinessCategory.active
                                           .where("name ILIKE ?", "#{query}%")
                                           .limit(3)
                                           .pluck(:name, :id)
                                           .map { |name, id|
                                             {
                                               type: 'category',
                                               text: name,
                                               subtitle: 'Service Category',
                                               value: name,
                                               category_id: id
                                             }
                                           }
      
      # Location suggestions using Google Places API
      if location.present?
        location_coords = extract_coordinates_from_location(location)
        place_suggestions = GeocodingService.places_autocomplete(query, location: location_coords)
                                          .first(3)
                                          .map { |place|
                                            {
                                              type: 'location',
                                              text: place[:main_text],
                                              subtitle: place[:secondary_text],
                                              value: place[:description],
                                              place_id: place[:place_id]
                                            }
                                          }
        suggestions.concat(place_suggestions)
      end
      
      suggestions.concat(business_suggestions)
      suggestions.concat(category_suggestions)
    end
    
    render json: {
      success: true,
      data: {
        suggestions: suggestions.first(10)
      }
    }
  end
  
  # GET /api/v1/search/suggestions
  def suggestions
    location = params[:location]
    
    suggestions = {
      popular_categories: BusinessCategory.joins(:businesses)
                                        .where(businesses: { business_status: 'approved' })
                                        .group('business_categories.id')
                                        .order('COUNT(businesses.id) DESC')
                                        .limit(8)
                                        .pluck(:name, :id)
                                        .map { |name, id| { name: name, id: id } },
      
      trending_searches: get_trending_searches,
      
      featured_businesses: Business.approved
                                 .featured
                                 .includes(:business_categories)
                                 .limit(6)
                                 .map { |business| business_summary_data(business) }
    }
    
    if location.present?
      suggestions[:local_categories] = get_local_categories(location)
      suggestions[:nearby_businesses] = get_nearby_businesses(location)
    end
    
    render json: {
      success: true,
      data: suggestions
    }
  end
  
  # POST /api/v1/search/save_search
  def save_search
    ensure_user!
    
    saved_search = current_user.saved_searches.build(saved_search_params)
    
    if saved_search.save
      render json: {
        success: true,
        message: 'Search saved successfully',
        data: { saved_search: saved_search_data(saved_search) }
      }, status: :created
    else
      render json: {
        success: false,
        message: 'Failed to save search',
        errors: saved_search.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
  
  # GET /api/v1/search/saved_searches
  def saved_searches
    ensure_user!
    
    searches = current_user.saved_searches.active.order(created_at: :desc)
    
    render json: {
      success: true,
      data: {
        saved_searches: searches.map { |search| saved_search_data(search) }
      }
    }
  end
  
  # DELETE /api/v1/search/saved_searches
  def destroy_saved_search
    ensure_user!
    
    search = current_user.saved_searches.find(params[:id])
    search.update!(active: false)
    
    render json: {
      success: true,
      message: 'Saved search removed'
    }
  end
  
  private
  
  def search_params
    params.permit(
      :query, :location, :radius, :sort_by, :page, :per_page,
      category_ids: [],
      filters: [
        :verified, :featured, :emergency_service, :insured, :licensed,
        :military_owned, :min_rating, :state, :city, :employee_count,
        :years_in_business
      ]
    ).to_h.deep_symbolize_keys
  end
  
  def saved_search_params
    params.require(:saved_search).permit(
      :search_name, :email_notifications, :notification_frequency,
      search_params: {}
    )
  end
  
  def extract_coordinates_from_location(location)
    if location.match?(/^-?\d+\.?\d*,-?\d+\.?\d*$/)
      lat, lng = location.split(',').map(&:to_f)
      { lat: lat, lng: lng }
    else
      result = GeocodingService.geocode(location)
      result ? { lat: result[:lat], lng: result[:lng] } : nil
    end
  end
  
  def get_trending_searches
    # This would typically come from analytics data
    # For now, return some popular searches
    [
      'Plumbing', 'Electrical', 'HVAC', 'Roofing', 'Landscaping',
      'Home Cleaning', 'Handyman', 'Real Estate', 'Auto Repair'
    ].map { |search| { query: search, count: rand(50..200) } }
  end
  
  def get_local_categories(location)
    coords = extract_coordinates_from_location(location)
    return [] unless coords
    
    # Get categories of businesses near the location
    Business.approved
            .near_location(coords[:lat], coords[:lng], 25)
            .joins(:business_categories)
            .group('business_categories.id', 'business_categories.name')
            .order('COUNT(businesses.id) DESC')
            .limit(6)
            .pluck('business_categories.name', 'business_categories.id', 'COUNT(businesses.id)')
            .map { |name, id, count| { name: name, id: id, local_count: count } }
  end
  
  def get_nearby_businesses(location)
    coords = extract_coordinates_from_location(location)
    return [] unless coords
    
    Business.approved
            .near_location(coords[:lat], coords[:lng], 10)
            .featured
            .limit(4)
            .map { |business| 
              data = business_summary_data(business)
              data[:distance] = business.distance_from(coords[:lat], coords[:lng])
              data
            }
  end
  
  def business_summary_data(business)
    {
      id: business.id,
      business_name: business.business_name,
      slug: business.slug,
      description: business.description&.truncate(100),
      city: business.city,
      state: business.state,
      average_rating: business.average_rating,
      total_reviews: business.total_reviews,
      featured: business.featured?,
      verified: business.verified?,
      military_owned: business.military_owned?,
      primary_image: business.images.attached? ? url_for(business.images.first) : nil,
      categories: business.business_categories.active.pluck(:name)
    }
  end
  
  def saved_search_data(search)
    {
      id: search.id,
      search_name: search.search_name,
      search_params: search.search_params,
      email_notifications: search.email_notifications,
      notification_frequency: search.notification_frequency,
      created_at: search.created_at
    }
  end
  
  def available_filters
    {
      categories: BusinessCategory.active.order(:name).pluck(:id, :name),
      states: Business.approved.distinct.pluck(:state).compact.sort,
      cities: Business.approved.distinct.pluck(:city).compact.sort,
      rating_options: [
        { value: 4.5, label: '4.5+ Stars' },
        { value: 4.0, label: '4.0+ Stars' },
        { value: 3.5, label: '3.5+ Stars' },
        { value: 3.0, label: '3.0+ Stars' }
      ]
    }
  end
end