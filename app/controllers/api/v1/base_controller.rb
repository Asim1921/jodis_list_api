# app/controllers/api/v1/base_controller.rb
class Api::V1::BaseController < ApplicationController
  before_action :authenticate_user!
  
  protected

  def authenticate_user!
    @current_user = JwtService.current_user(request)
    
    unless @current_user
      render json: {
        success: false,
        message: 'Authentication required'
      }, status: :unauthorized
      return
    end
  end

  def current_user
    @current_user
  end

  def ensure_admin!
    unless current_user&.admin?
      render json: {
        success: false,
        message: 'Admin access required'
      }, status: :forbidden
    end
  end

  def ensure_business_owner!
    unless current_user&.business_owner? || current_user&.admin?
      render json: {
        success: false,
        message: 'Business owner access required'
      }, status: :forbidden
    end
  end

  def paginate_collection(collection, per_page: 20)
    page = params[:page]&.to_i || 1
    per_page = [params[:per_page]&.to_i || per_page, 100].min

    collection.page(page).per(per_page)
  end

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count,
      per_page: collection.limit_value
    }
  end
end