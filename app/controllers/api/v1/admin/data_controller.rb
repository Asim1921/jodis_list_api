# app/controllers/api/v1/admin/data_controller.rb
class Api::V1::Admin::DataController < Api::V1::BaseController
  before_action :ensure_admin!
  
  # POST /api/v1/admin/data/scrape_veteran_directory
  def scrape_veteran_directory
    options = {
      states: params[:states] || nil,
      limit: params[:limit] || nil
    }
    
    # Queue the scraping job
    VeteranDirectoryScrapingJob.perform_later(options)
    
    render json: {
      success: true,
      message: 'Veteran directory scraping job started. This may take several minutes.',
      job_id: 'veteran_scraping_' + Time.current.to_i.to_s
    }
  end
  
  # GET /api/v1/admin/data/scraping_status
  def scraping_status
    cached_results = Rails.cache.read('last_scraping_results')
    
    if cached_results
      render json: {
        success: true,
        data: {
          last_run: cached_results[:completed_at],
          stats: cached_results[:stats],
          errors: cached_results[:errors],
          status: 'completed'
        }
      }
    else
      render json: {
        success: true,
        data: {
          status: 'no_previous_runs',
          message: 'No scraping jobs have been completed yet'
        }
      }
    end
  end
  
  # POST /api/v1/admin/data/import_businesses
  def import_businesses
    file = params[:file]
    
    unless file && file.respond_to?(:read)
      render json: {
        success: false,
        message: 'Please provide a valid CSV file'
      }, status: :bad_request
      return
    end
    
    # Queue import job
    BusinessImportJob.perform_later(file.read, current_user.id)
    
    render json: {
      success: true,
      message: 'Business import started. You will receive an email when complete.'
    }
  end
  
  # GET /api/v1/admin/data/export_businesses
  def export_businesses
    businesses = Business.includes(:user, :business_categories, :reviews)
    
    csv_data = generate_businesses_csv(businesses)
    
    send_data csv_data,
              filename: "jodis_list_businesses_#{Date.current}.csv",
              type: 'text/csv'
  end
  
  private
  
  def generate_businesses_csv(businesses)
    CSV.generate(headers: true) do |csv|
      csv << [
        'ID', 'Business Name', 'Owner Name', 'Email', 'Phone', 'Website',
        'Address', 'City', 'State', 'ZIP', 'Categories', 'Status',
        'Rating', 'Reviews', 'Military Owned', 'Created At'
      ]
      
      businesses.find_each do |business|
        csv << [
          business.id,
          business.business_name,
          business.user.full_name,
          business.business_email || business.user.email,
          business.business_phone,
          business.website_url,
          business.full_address,
          business.city,
          business.state,
          business.zip_code,
          business.business_categories.pluck(:name).join('; '),
          business.business_status,
          business.average_rating,
          business.total_reviews,
          business.military_owned?,
          business.created_at
        ]
      end
    end
  end
end