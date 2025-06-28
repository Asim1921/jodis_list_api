# app/models/business.rb - Updated with search functionality
class Business < ApplicationRecord
  belongs_to :user
  has_one :real_estate_agent, dependent: :destroy
  has_many :business_category_assignments, dependent: :destroy
  has_many :business_categories, through: :business_category_assignments
  has_many :reviews, dependent: :destroy
  has_many :inquiries, dependent: :destroy
  has_many_attached :images
  has_many_attached :documents
  has_many_attached :certifications

  # Fixed enum syntax for Rails 8
  enum :business_status, { 
    pending: 0, 
    approved: 1, 
    rejected: 2, 
    suspended: 3 
  } 

  # Validations
  validates :business_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :business_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :business_phone, format: { with: /\A[\+]?[1-9][\d]{0,15}\z/ }, allow_blank: true
  validates :areas_served, presence: true
  validates :description, length: { maximum: 2000 }
  validates :website_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true
  validates :slug, uniqueness: true, allow_blank: true

  # Callbacks
  before_save :generate_slug
  before_save :geocode_address, if: :address_changed?

  # Basic Scopes
  scope :approved, -> { where(business_status: :approved) }
  scope :featured, -> { where(featured: true) }
  scope :verified, -> { where(verified: true) }
  scope :by_membership_priority, -> { joins(:user).order('users.membership_status ASC') }

  # Search Scopes - ADD THESE MISSING METHODS
  scope :search_by_keyword, ->(keyword) {
    return all if keyword.blank?
    
    sanitized_keyword = "%#{keyword.to_s.strip}%"
    where(
      "business_name ILIKE :keyword OR description ILIKE :keyword OR areas_served ILIKE :keyword OR services_offered ILIKE :keyword",
      keyword: sanitized_keyword
    )
  }

  scope :by_category, ->(category_id) {
    return all if category_id.blank?
    
    joins(:business_categories).where(business_categories: { id: category_id })
  }

  scope :by_location, ->(city, state, zip_code) {
    scope = all
    scope = scope.where("city ILIKE ?", "%#{city}%") if city.present?
    scope = scope.where("state ILIKE ?", "%#{state}%") if state.present?
    scope = scope.where("zip_code = ?", zip_code) if zip_code.present?
    scope
  }

  scope :by_military_status, ->(status) {
    return all if status.blank?
    
    joins(user: :military_background)
      .where(military_backgrounds: { military_relationship: status })
  }

  # Location-based search with fallback options
  scope :nearby, ->(latitude, longitude, radius_miles = 25) {
    return all if latitude.blank? || longitude.blank?

    lat = latitude.to_f
    lng = longitude.to_f
    radius = radius_miles.to_f

    # Check if PostGIS is available
    if connection.extension_enabled?('postgis')
      # Use PostGIS for accurate distance calculation
      radius_meters = radius * 1609.34
      where(
        "ST_DWithin(ST_MakePoint(longitude, latitude)::geography, ST_MakePoint(?, ?)::geography, ?)",
        lng, lat, radius_meters
      ).order(
        Arel.sql("ST_Distance(ST_MakePoint(longitude, latitude)::geography, ST_MakePoint(#{lng}, #{lat})::geography)")
      )
    elsif connection.extension_enabled?('earthdistance')
      # Use earthdistance extension
      radius_meters = radius * 1609.34
      where(
        "earth_distance(ll_to_earth(?, ?), ll_to_earth(latitude, longitude)) < ?",
        lat, lng, radius_meters
      ).order(
        Arel.sql("earth_distance(ll_to_earth(#{lat}, #{lng}), ll_to_earth(latitude, longitude))")
      )
    else
      # Fallback to basic coordinate-based distance (less accurate but works)
      # Using Haversine formula approximation for small distances
      where(
        "((latitude - ?)*(latitude - ?) + (longitude - ?)*(longitude - ?)) < ?",
        lat, lat, lng, lng, (radius / 69.0) ** 2 # Rough conversion
      ).order(
        Arel.sql("((latitude - #{lat})*(latitude - #{lat}) + (longitude - #{lng})*(longitude - #{lng}))")
      )
    end
  }

  # Legacy scope name for backward compatibility
  scope :near_location, ->(lat, lng, radius = 25) { nearby(lat, lng, radius) }

  # Additional search scopes
  scope :with_emergency_service, -> { where(emergency_service: true) }
  scope :insured_businesses, -> { where(insured: true) }
  scope :bonded_businesses, -> { where(bonded: true) }
  scope :with_keywords, ->(keywords) {
    return all if keywords.blank?
    
    keyword_array = keywords.is_a?(Array) ? keywords : [keywords]
    where("keywords && ARRAY[?]::varchar[]", keyword_array)
  }

  scope :by_payment_method, ->(method) {
    return all if method.blank?
    
    where("? = ANY(payment_methods)", method)
  }

  scope :by_language, ->(language) {
    return all if language.blank?
    
    where("? = ANY(languages_spoken)", language)
  }

  # Combined search method for complex queries
  def self.advanced_search(params = {})
    scope = approved.includes(:user, :business_categories, :reviews)
    
    # Keyword search
    if params[:q].present?
      scope = scope.search_by_keyword(params[:q])
    end
    
    # Category filter
    if params[:category_id].present?
      scope = scope.by_category(params[:category_id])
    end
    
    # Location filters
    if params[:city].present? || params[:state].present? || params[:zip_code].present?
      scope = scope.by_location(params[:city], params[:state], params[:zip_code])
    end
    
    # Nearby search
    if params[:latitude].present? && params[:longitude].present?
      radius = params[:radius]&.to_i || 25
      scope = scope.nearby(params[:latitude], params[:longitude], radius)
    end
    
    # Service filters
    scope = scope.with_emergency_service if params[:emergency_service] == 'true'
    scope = scope.insured_businesses if params[:insured] == 'true'
    scope = scope.bonded_businesses if params[:bonded] == 'true'
    scope = scope.featured if params[:featured] == 'true'
    scope = scope.verified if params[:verified] == 'true'
    
    # Military status filter
    if params[:military_status].present?
      scope = scope.by_military_status(params[:military_status])
    end
    
    # Keywords filter
    if params[:keywords].present?
      scope = scope.with_keywords(params[:keywords])
    end
    
    # Payment method filter
    if params[:payment_method].present?
      scope = scope.by_payment_method(params[:payment_method])
    end
    
    # Language filter
    if params[:language].present?
      scope = scope.by_language(params[:language])
    end
    
    # Rating filter
    if params[:min_rating].present?
      min_rating = params[:min_rating].to_f
      scope = scope.joins(:reviews)
                   .group('businesses.id')
                   .having('AVG(reviews.rating) >= ?', min_rating)
    end
    
    scope
  end

  # Instance Methods
  def average_rating
    reviews.where(active: true).average(:rating)&.round(1) || 0.0
  end

  def total_reviews
    reviews.where(active: true).count
  end

  def full_address
    components = [address_line1, address_line2, city, state, zip_code].compact.reject(&:blank?)
    components.join(', ')
  end

  def military_owned?
    user.veteran? || user.military_background&.verified?
  end

  def distance_from(lat, lng)
    return nil unless latitude && longitude
    
    rad_per_deg = Math::PI / 180
    rkm = 6371 # Earth radius in kilometers
    rm = rkm * 1000 # Earth radius in meters

    dlat_rad = (lat - latitude) * rad_per_deg
    dlon_rad = (lng - longitude) * rad_per_deg

    lat1_rad = latitude * rad_per_deg
    lat2_rad = lat * rad_per_deg

    a = Math.sin(dlat_rad / 2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    (rm * c / 1609.34).round(2) # Distance in miles
  end

  private

  def generate_slug
    return if slug.present?
    
    base_slug = business_name.parameterize
    counter = 1
    potential_slug = base_slug
    
    while Business.exists?(slug: potential_slug)
      potential_slug = "#{base_slug}-#{counter}"
      counter += 1
    end
    
    self.slug = potential_slug
  end

  def address_changed?
    address_line1_changed? || city_changed? || state_changed? || zip_code_changed?
  end

  def geocode_address
    # This would integrate with a geocoding service like Google Maps API
    # For now, we'll leave it as a placeholder
    # Implementation would go here to set latitude and longitude
  end
end