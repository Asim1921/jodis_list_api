# app/controllers/api/v1/business_categories_controller.rb
class Api::V1::BusinessCategoriesController < Api::V1::BaseController
  skip_before_action :authenticate_user!
  before_action :set_category, only: [:show, :businesses]

  def index
    @categories = BusinessCategory.active.ordered

    render json: {
      success: true,
      data: {
        categories: @categories.map { |category| category_data(category) }
      }
    }
  end

  def show
    render json: {
      success: true,
      data: {
        category: detailed_category_data(@category)
      }
    }
  end

  def businesses
    @businesses = @category.businesses
                          .approved
                          .includes(:user, :business_categories, :reviews)
                          .by_membership_priority

    @businesses = paginate_collection(@businesses)

    render json: {
      success: true,
      data: {
        businesses: @businesses.map { |business| business_summary_data(business) },
        meta: pagination_meta(@businesses),
        category: category_data(@category)
      }
    }
  end

  private

  def set_category
    @category = BusinessCategory.find(params[:id])
  end

  def category_data(category)
    {
      id: category.id,
      name: category.name,
      description: category.description,
      icon_class: category.icon_class,
      businesses_count: category.businesses_count,
      sort_order: category.sort_order
    }
  end

  def detailed_category_data(category)
    data = category_data(category)
    data.merge!({
      active: category.active?,
      created_at: category.created_at,
      updated_at: category.updated_at
    })
  end

  def business_summary_data(business)
    # Use the same method from BusinessesController
    Api::V1::BusinessesController.new.send(:business_summary_data, business)
  end
end