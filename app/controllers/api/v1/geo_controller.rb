class Api::V1::GeoController < Api::V1::BaseController
  skip_before_action :authenticate_user!
  
  # GET /api/v1/geo/states
  def states
    states = Business.approved.distinct.pluck(:state).compact.sort
    state_data = states.map do |state|
      business_count = Business.approved.where(state: state).count
      {
        code: state,
        name: state_name_from_code(state),
        business_count: business_count
      }
    end
    
    render json: {
      success: true,
      data: { states: state_data }
    }
  end
  
  # GET /api/v1/geo/cities
  def cities
    state = params[:state]
    cities_query = Business.approved.distinct
    cities_query = cities_query.where(state: state) if state.present?
    
    cities = cities_query.pluck(:city, :state).compact.map do |city, state|
      business_count = Business.approved.where(city: city, state: state).count
      {
        name: city,
        state: state,
        business_count: business_count
      }
    end.sort_by { |city| city[:name] }
    
    render json: {
      success: true,
      data: { cities: cities }
    }
  end
  
  # GET /api/v1/geo/zip_codes
  def zip_codes
    state = params[:state]
    city = params[:city]
    
    zip_query = Business.approved.distinct
    zip_query = zip_query.where(state: state) if state.present?
    zip_query = zip_query.where(city: city) if city.present?
    
    zip_codes = zip_query.pluck(:zip_code).compact.sort
    
    render json: {
      success: true,
      data: { zip_codes: zip_codes }
    }
  end
  
  # POST /api/v1/geo/geocode
  def geocode
    address = params[:address]
    
    if address.present?
      result = GeocodingService.geocode(address)
      
      if result
        render json: {
          success: true,
          data: { location: result }
        }
      else
        render json: {
          success: false,
          message: 'Unable to geocode address'
        }, status: :unprocessable_entity
      end
    else
      render json: {
        success: false,
        message: 'Address is required'
      }, status: :bad_request
    end
  end
  
  # POST /api/v1/geo/reverse_geocode
  def reverse_geocode
    lat = params[:latitude]&.to_f
    lng = params[:longitude]&.to_f
    
    if lat && lng
      result = GeocodingService.reverse_geocode(lat, lng)
      
      if result
        render json: {
          success: true,
          data: { location: result }
        }
      else
        render json: {
          success: false,
          message: 'Unable to reverse geocode coordinates'
        }, status: :unprocessable_entity
      end
    else
      render json: {
        success: false,
        message: 'Latitude and longitude are required'
      }, status: :bad_request
    end
  end
  
  # GET /api/v1/geo/service_areas
  def service_areas
    business_id = params[:business_id]
    location = params[:location]
    
    if business_id.present?
      business = Business.find(business_id)
      areas = business.service_area_array
      
      render json: {
        success: true,
        data: {
          service_areas: areas,
          serves_location: location.present? ? business.serves_area?(location) : nil
        }
      }
    else
      # Return all unique service areas
      all_areas = Business.approved
                         .where.not(areas_served: [nil, ''])
                         .pluck(:areas_served)
                         .flat_map { |areas| areas.split(',').map(&:strip) }
                         .uniq
                         .sort
      
      render json: {
        success: true,
        data: { service_areas: all_areas }
      }
    end
  end
  
  private
  
  def state_name_from_code(code)
    state_names = {
      'AL' => 'Alabama', 'AK' => 'Alaska', 'AZ' => 'Arizona', 'AR' => 'Arkansas',
      'CA' => 'California', 'CO' => 'Colorado', 'CT' => 'Connecticut', 'DE' => 'Delaware',
      'FL' => 'Florida', 'GA' => 'Georgia', 'HI' => 'Hawaii', 'ID' => 'Idaho',
      'IL' => 'Illinois', 'IN' => 'Indiana', 'IA' => 'Iowa', 'KS' => 'Kansas',
      'KY' => 'Kentucky', 'LA' => 'Louisiana', 'ME' => 'Maine', 'MD' => 'Maryland',
      'MA' => 'Massachusetts', 'MI' => 'Michigan', 'MN' => 'Minnesota', 'MS' => 'Mississippi',
      'MO' => 'Missouri', 'MT' => 'Montana', 'NE' => 'Nebraska', 'NV' => 'Nevada',
      'NH' => 'New Hampshire', 'NJ' => 'New Jersey', 'NM' => 'New Mexico', 'NY' => 'New York',
      'NC' => 'North Carolina', 'ND' => 'North Dakota', 'OH' => 'Ohio', 'OK' => 'Oklahoma',
      'OR' => 'Oregon', 'PA' => 'Pennsylvania', 'RI' => 'Rhode Island', 'SC' => 'South Carolina',
      'SD' => 'South Dakota', 'TN' => 'Tennessee', 'TX' => 'Texas', 'UT' => 'Utah',
      'VT' => 'Vermont', 'VA' => 'Virginia', 'WA' => 'Washington', 'WV' => 'West Virginia',
      'WI' => 'Wisconsin', 'WY' => 'Wyoming', 'DC' => 'District of Columbia'
    }
    
    state_names[code] || code
  end
end