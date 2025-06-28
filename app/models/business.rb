# app/models/business.rb
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

  # Scopes
  scope :approved, -> { where(business_status: :approved) }
  scope :featured, -> { where(featured: true) }
  scope :verified, -> { where(verified: true) }
  scope :by_membership_priority, -> { joins(:user).order('users.membership_status ASC') }
  scope :near_location, ->(lat, lng, radius = 25) {
    where(
      "earth_distance(ll_to_earth(?, ?), ll_to_earth(latitude, longitude)) < ?",
      lat, lng, radius * 1609.34 # Convert miles to meters
    )
  }

  # Methods
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