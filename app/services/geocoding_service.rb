# app/services/geocoding_service.rb
class GeocodingService
  include HTTParty
  
  GOOGLE_MAPS_API_KEY = Rails.application.credentials.google_maps_api_key
  BASE_URL = 'https://maps.googleapis.com/maps/api/geocode/json'
  PLACES_API_URL = 'https://maps.googleapis.com/maps/api/place'
  
  class << self
    # Geocode an address to get coordinates
    def geocode(address)
      return nil if address.blank? || GOOGLE_MAPS_API_KEY.blank?
      
      response = HTTParty.get(BASE_URL, {
        query: {
          address: address,
          key: GOOGLE_MAPS_API_KEY,
          region: 'us' # Bias results to US
        },
        timeout: 10
      })
      
      if response.success? && response['status'] == 'OK'
        result = response['results'].first
        location = result['geometry']['location']
        
        {
          lat: location['lat'],
          lng: location['lng'],
          formatted_address: result['formatted_address'],
          place_id: result['place_id'],
          address_components: parse_address_components(result['address_components'])
        }
      else
        Rails.logger.error "Geocoding failed: #{response['status']} - #{response['error_message']}"
        nil
      end
    rescue => e
      Rails.logger.error "Geocoding service error: #{e.message}"
      nil
    end
    
    # Reverse geocode coordinates to get address
    def reverse_geocode(lat, lng)
      return nil if lat.blank? || lng.blank? || GOOGLE_MAPS_API_KEY.blank?
      
      response = HTTParty.get(BASE_URL, {
        query: {
          latlng: "#{lat},#{lng}",
          key: GOOGLE_MAPS_API_KEY,
          result_type: 'street_address|route|locality|administrative_area_level_1'
        },
        timeout: 10
      })
      
      if response.success? && response['status'] == 'OK'
        result = response['results'].first
        location = result['geometry']['location']
        
        {
          lat: location['lat'],
          lng: location['lng'],
          formatted_address: result['formatted_address'],
          place_id: result['place_id'],
          address_components: parse_address_components(result['address_components'])
        }
      else
        Rails.logger.error "Reverse geocoding failed: #{response['status']} - #{response['error_message']}"
        nil
      end
    rescue => e
      Rails.logger.error "Reverse geocoding service error: #{e.message}"
      nil
    end
    
    # Get place details from Google Places API
    def place_details(place_id)
      return nil if place_id.blank? || GOOGLE_MAPS_API_KEY.blank?
      
      response = HTTParty.get("#{PLACES_API_URL}/details/json", {
        query: {
          place_id: place_id,
          key: GOOGLE_MAPS_API_KEY,
          fields: 'name,formatted_address,geometry,place_id,formatted_phone_number,website,opening_hours,rating,user_ratings_total,photos'
        },
        timeout: 10
      })
      
      if response.success? && response['status'] == 'OK'
        response['result']
      else
        Rails.logger.error "Place details failed: #{response['status']} - #{response['error_message']}"
        nil
      end
    rescue => e
      Rails.logger.error "Place details service error: #{e.message}"
      nil
    end
    
    # Places autocomplete for search suggestions
    def places_autocomplete(input, location: nil, radius: 50000)
      return [] if input.blank? || GOOGLE_MAPS_API_KEY.blank?
      
      query_params = {
        input: input,
        key: GOOGLE_MAPS_API_KEY,
        types: 'address',
        region: 'us',
        components: 'country:us'
      }
      
      if location.present?
        query_params[:location] = "#{location[:lat]},#{location[:lng]}"
        query_params[:radius] = radius
      end
      
      response = HTTParty.get("#{PLACES_API_URL}/autocomplete/json", {
        query: query_params,
        timeout: 10
      })
      
      if response.success? && response['status'] == 'OK'
        response['predictions'].map do |prediction|
          {
            place_id: prediction['place_id'],
            description: prediction['description'],
            main_text: prediction['structured_formatting']['main_text'],
            secondary_text: prediction['structured_formatting']['secondary_text'],
            types: prediction['types']
          }
        end
      else
        Rails.logger.error "Places autocomplete failed: #{response['status']} - #{response['error_message']}"
        []
      end
    rescue => e
      Rails.logger.error "Places autocomplete service error: #{e.message}"
      []
    end
    
    # Calculate distance between two points using Google Distance Matrix API
    def calculate_distance(origin, destination, mode: 'driving')
      return nil if origin.blank? || destination.blank? || GOOGLE_MAPS_API_KEY.blank?
      
      response = HTTParty.get('https://maps.googleapis.com/maps/api/distancematrix/json', {
        query: {
          origins: format_location(origin),
          destinations: format_location(destination),
          key: GOOGLE_MAPS_API_KEY,
          mode: mode,
          units: 'imperial',
          avoid: 'tolls'
        },
        timeout: 10
      })
      
      if response.success? && response['status'] == 'OK'
        element = response['rows'].first['elements'].first
        
        if element['status'] == 'OK'
          {
            distance: {
              text: element['distance']['text'],
              value_miles: (element['distance']['value'] * 0.000621371).round(2)
            },
            duration: {
              text: element['duration']['text'],
              value_seconds: element['duration']['value']
            }
          }
        else
          nil
        end
      else
        Rails.logger.error "Distance calculation failed: #{response['status']}"
        nil
      end
    rescue => e
      Rails.logger.error "Distance calculation service error: #{e.message}"
      nil
    end
    
    # Batch geocode multiple addresses
    def batch_geocode(addresses)
      return [] if addresses.blank?
      
      results = []
      addresses.each_slice(10) do |batch| # Process in batches to avoid rate limits
        batch.each do |address|
          result = geocode(address)
          results << { address: address, result: result }
          sleep(0.1) # Small delay to respect rate limits
        end
      end
      
      results
    end
    
    # Validate if coordinates are within US bounds
    def within_us_bounds?(lat, lng)
      # Rough US bounds
      lat_bounds = [24.396308, 49.384358] # South to North
      lng_bounds = [-125.0, -66.93457] # West to East
      
      lat.between?(lat_bounds[0], lat_bounds[1]) && 
      lng.between?(lng_bounds[0], lng_bounds[1])
    end
    
    # Get timezone for coordinates
    def get_timezone(lat, lng)
      return nil if lat.blank? || lng.blank? || GOOGLE_MAPS_API_KEY.blank?
      
      response = HTTParty.get('https://maps.googleapis.com/maps/api/timezone/json', {
        query: {
          location: "#{lat},#{lng}",
          timestamp: Time.current.to_i,
          key: GOOGLE_MAPS_API_KEY
        },
        timeout: 10
      })
      
      if response.success? && response['status'] == 'OK'
        {
          timezone_id: response['timeZoneId'],
          timezone_name: response['timeZoneName'],
          dst_offset: response['dstOffset'],
          raw_offset: response['rawOffset']
        }
      else
        nil
      end
    rescue => e
      Rails.logger.error "Timezone service error: #{e.message}"
      nil
    end
    
    private
    
    def parse_address_components(components)
      parsed = {}
      
      components.each do |component|
        types = component['types']
        
        if types.include?('street_number')
          parsed[:street_number] = component['long_name']
        elsif types.include?('route')
          parsed[:street_name] = component['long_name']
        elsif types.include?('locality')
          parsed[:city] = component['long_name']
        elsif types.include?('administrative_area_level_1')
          parsed[:state] = component['short_name']
          parsed[:state_long] = component['long_name']
        elsif types.include?('administrative_area_level_2')
          parsed[:county] = component['long_name']
        elsif types.include?('postal_code')
          parsed[:zip_code] = component['long_name']
        elsif types.include?('country')
          parsed[:country] = component['short_name']
          parsed[:country_long] = component['long_name']
        elsif types.include?('sublocality') || types.include?('neighborhood')
          parsed[:neighborhood] = component['long_name']
        end
      end
      
      # Construct full street address
      if parsed[:street_number] && parsed[:street_name]
        parsed[:street_address] = "#{parsed[:street_number]} #{parsed[:street_name]}"
      elsif parsed[:street_name]
        parsed[:street_address] = parsed[:street_name]
      end
      
      parsed
    end
    
    def format_location(location)
      case location
      when Hash
        if location[:lat] && location[:lng]
          "#{location[:lat]},#{location[:lng]}"
        elsif location[:address]
          location[:address]
        else
          location.values.join(', ')
        end
      when Array
        location.join(',')
      else
        location.to_s
      end
    end
  end
end

# app/services/business_search_service.rb
class BusinessSearchService
  include ActiveModel::Model
  
  attr_accessor :query, :location, :category_ids, :radius, :filters, :sort_by, :page, :per_page
  
  def initialize(params = {})
    @query = params[:query]
    @location = params[:location] # can be address, city, state, or coordinates
    @category_ids = Array(params[:category_ids]).reject(&:blank?)
    @radius = (params[:radius] || 25).to_i
    @filters = params[:filters] || {}
    @sort_by = params[:sort_by] || 'relevance'
    @page = (params[:page] || 1).to_i
    @per_page = (params[:per_page] || 20).to_i
  end
  
  def search
    @businesses = Business.approved.includes(:user, :business_categories, :reviews, images_attachments: :blob)
    
    apply_keyword_search
    apply_location_search
    apply_category_filter
    apply_advanced_filters
    apply_sorting
    
    {
      businesses: paginate_results,
      total_count: @businesses.count,
      current_page: @page,
      total_pages: (@businesses.count.to_f / @per_page).ceil,
      search_metadata: search_metadata
    }
  end
  
  private
  
  def apply_keyword_search
    return unless @query.present?
    
    # Enhanced search with ranking
    @businesses = @businesses.where(
      "to_tsvector('english', business_name || ' ' || coalesce(description, '') || ' ' || coalesce(areas_served, '')) @@ plainto_tsquery('english', ?)",
      @query
    ).or(
      @businesses.where(
        "business_name ILIKE ? OR description ILIKE ? OR areas_served ILIKE ?",
        "%#{@query}%", "%#{@query}%", "%#{@query}%"
      )
    )
  end
  
  def apply_location_search
    return unless @location.present?
    
    coordinates = extract_coordinates(@location)
    
    if coordinates
      # Location-based search with radius
      @businesses = @businesses.near_location(coordinates[:lat], coordinates[:lng], @radius)
      @search_coordinates = coordinates
    else
      # Text-based location search
      @businesses = @businesses.where(
        "city ILIKE ? OR state ILIKE ? OR areas_served ILIKE ?",
        "%#{@location}%", "%#{@location}%", "%#{@location}%"
      )
    end
  end
  
  def apply_category_filter
    return unless @category_ids.any?
    
    @businesses = @businesses.joins(:business_categories)
                            .where(business_categories: { id: @category_ids })
                            .distinct
  end
  
  def apply_advanced_filters
    @businesses = @businesses.verified if @filters[:verified] == 'true'
    @businesses = @businesses.featured if @filters[:featured] == 'true'
    @businesses = @businesses.emergency_services if @filters[:emergency_service] == 'true'
    @businesses = @businesses.insured if @filters[:insured] == 'true'
    @businesses = @businesses.licensed if @filters[:licensed] == 'true'
    
    # Military owned filter
    if @filters[:military_owned] == 'true'
      @businesses = @businesses.joins(:user)
                              .joins('LEFT JOIN military_backgrounds ON military_backgrounds.user_id = users.id')
                              .where('users.role = ? OR military_backgrounds.verified = ?', 'veteran', true)
    end
    
    # Rating filter
    if @filters[:min_rating].present?
      min_rating = @filters[:min_rating].to_f
      @businesses = @businesses.joins(:reviews)
                              .group('businesses.id')
                              .having('AVG(reviews.rating) >= ?', min_rating)
    end
    
    # Geographic filters
    @businesses = @businesses.in_state(@filters[:state]) if @filters[:state].present?
    @businesses = @businesses.in_city(@filters[:city]) if @filters[:city].present?
    
    # Business size filter
    if @filters[:employee_count].present?
      case @filters[:employee_count]
      when 'small'
        @businesses = @businesses.where(employee_count: 1..10)
      when 'medium'
        @businesses = @businesses.where(employee_count: 11..50)
      when 'large'
        @businesses = @businesses.where(employee_count: 51..Float::INFINITY)
      end
    end
    
    # Years in business filter
    if @filters[:years_in_business].present?
      min_years = @filters[:years_in_business].to_i
      @businesses = @businesses.where('years_in_business >= ?', min_years)
    end
  end
  
  def apply_sorting
    case @sort_by
    when 'rating'
      @businesses = @businesses.left_joins(:reviews)
                              .group('businesses.id')
                              .order('AVG(reviews.rating) DESC NULLS LAST')
    when 'newest'
      @businesses = @businesses.order(created_at: :desc)
    when 'name'
      @businesses = @businesses.order(:business_name)
    when 'distance'
      if @search_coordinates
        # Sort by distance (requires custom logic with coordinates)
        @businesses = @businesses.to_a.sort_by do |business|
          business.distance_from(@search_coordinates[:lat], @search_coordinates[:lng]) || Float::INFINITY
        end
      else
        @businesses = @businesses.by_membership_priority
      end
    when 'membership'
      @businesses = @businesses.by_membership_priority
    else # relevance
      if @query.present?
        # Sort by relevance score for text search
        @businesses = @businesses.order(
          "ts_rank_cd(to_tsvector('english', business_name || ' ' || coalesce(description, '')), plainto_tsquery('english', '#{@query}')) DESC"
        )
      else
        @businesses = @businesses.by_membership_priority.by_rating
      end
    end
  end
  
  def paginate_results
    return @businesses[@per_page * (@page - 1), @per_page] if @businesses.is_a?(Array)
    
    @businesses.offset(@per_page * (@page - 1)).limit(@per_page)
  end
  
  def extract_coordinates(location_input)
    # Try to parse as coordinates first (lat,lng format)
    if location_input.match?(/^-?\d+\.?\d*,-?\d+\.?\d*$/)
      lat, lng = location_input.split(',').map(&:to_f)
      return { lat: lat, lng: lng }
    end
    
    # Try geocoding the address
    result = GeocodingService.geocode(location_input)
    return result if result
    
    nil
  end
  
  def search_metadata
    {
      query: @query,
      location: @location,
      coordinates: @search_coordinates,
      radius: @radius,
      category_ids: @category_ids,
      filters_applied: @filters,
      sort_by: @sort_by,
      total_results: @businesses.is_a?(Array) ? @businesses.count : @businesses.count
    }
  end
end