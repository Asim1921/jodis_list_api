# app/controllers/api/v1/users_controller.rb
class Api::V1::UsersController < Api::V1::BaseController
  before_action :set_user, only: [:show, :update]
  before_action :ensure_owner_or_admin, only: [:show, :update]

  def show
    render json: {
      success: true,
      data: {
        user: detailed_user_data(@user)
      }
    }
  end

  def update
    if @user.update(user_params)
      render json: {
        success: true,
        message: 'Profile updated successfully',
        data: {
          user: detailed_user_data(@user)
        }
      }
    else
      render json: {
        success: false,
        message: 'Update failed',
        errors: @user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def ensure_owner_or_admin
    unless @user == current_user || current_user.admin?
      render json: {
        success: false,
        message: 'Access denied'
      }, status: :forbidden
    end
  end

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :phone, :avatar
    )
  end

  def detailed_user_data(user)
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      full_name: user.full_name,
      phone: user.phone,
      role: user.role,
      membership_status: user.membership_status,
      active: user.active?,
      has_business: user.has_business?,
      military_verified: user.military_verified?,
      avatar_url: user.avatar.attached? ? url_for(user.avatar) : nil,
      business: user.business ? basic_business_data(user.business) : nil,
      military_background: user.military_background ? military_background_data(user.military_background) : nil,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
  end

  def basic_business_data(business)
    {
      id: business.id,
      business_name: business.business_name,
      slug: business.slug,
      business_status: business.business_status,
      featured: business.featured?,
      verified: business.verified?
    }
  end

  def military_background_data(military_background)
    {
      id: military_background.id,
      military_relationship: military_background.military_relationship,
      branch_of_service: military_background.branch_of_service,
      rank: military_background.rank,
      verified: military_background.verified?
    }
  end
end