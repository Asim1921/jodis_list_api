# app/controllers/api/v1/public_controller.rb
class Api::V1::PublicController < Api::V1::BaseController
  skip_before_action :authenticate_user!

  # GET /api/v1/public/businesses/featured
  def featured
    @businesses = Business.approved
                         .featured
                         .includes(:user, :business_categories, :reviews)
                         .by_membership_priority
                         .limit(6)

    render json: {
      success: true,
      data: {
        businesses: @businesses.map { |business| business_summary_data(business) }
      }
    }
  end

  # GET /api/v1/public/businesses/search
  def search
    @businesses = Business.approved.includes(:user, :business_categories, :reviews)
    
    # Keyword search
    if params[:q].present?
      keyword = "%#{params[:q].strip}%"
      @businesses = @businesses.where(
        "businesses.business_name ILIKE ? OR businesses.description ILIKE ?",
        keyword, keyword
      )
    end
    
    # Category filter
    if params[:category_ids].present?
      category_ids = params[:category_ids].is_a?(Array) ? params[:category_ids] : [params[:category_ids]]
      @businesses = @businesses.joins(:business_categories).where(business_categories: { id: category_ids })
    end
    
    @businesses = @businesses.limit(12)

    render json: {
      success: true,
      data: {
        businesses: @businesses.map { |business| business_summary_data(business) }
      }
    }
  end

  # GET /api/v1/public/statistics
  def statistics
    stats = Rails.cache.fetch('public_statistics', expires_in: 1.hour) do
      {
        total_businesses: Business.approved.count,
        total_veterans: User.joins(:military_background).where(military_backgrounds: { verified: true }).count,
        total_categories: BusinessCategory.active.count,
        total_reviews: Review.active.count
      }
    end

    render json: {
      success: true,
      data: stats
    }
  end

  private

  def business_summary_data(business)
    {
      id: business.id,
      business_name: business.business_name,
      slug: business.slug,
      description: business.description&.truncate(150),
      business_phone: business.business_phone,
      business_email: business.business_email,
      website_url: business.website_url,
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
end