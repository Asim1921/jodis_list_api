# app/jobs/geocoding_job.rb
class GeocodingJob < ApplicationJob
  queue_as :default
  
  def perform(business_id)
    business = Business.find_by(id: business_id)
    return unless business
    
    # Skip if already geocoded
    return if business.latitude.present? && business.longitude.present?
    
    # Geocode the business address
    result = GeocodingService.geocode(business.full_address)
    
    if result
      business.update!(
        latitude: result[:lat],
        longitude: result[:lng]
      )
      Rails.logger.info "Geocoded business #{business.id}: #{business.business_name}"
    else
      Rails.logger.warn "Failed to geocode business #{business.id}: #{business.business_name}"
    end
  rescue => e
    Rails.logger.error "Geocoding job failed for business #{business_id}: #{e.message}"
  end
end