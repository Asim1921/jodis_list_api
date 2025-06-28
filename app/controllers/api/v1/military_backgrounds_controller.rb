# app/controllers/api/v1/military_backgrounds_controller.rb
class Api::V1::MilitaryBackgroundsController < Api::V1::BaseController
  before_action :set_user
  before_action :ensure_owner_or_admin
  before_action :set_military_background, only: [:show, :update, :destroy]

  def show
    if @military_background
      render json: {
        success: true,
        data: {
          military_background: military_background_data(@military_background)
        }
      }
    else
      render json: {
        success: false,
        message: 'Military background not found'
      }, status: :not_found
    end
  end

  def create
    @military_background = @user.build_military_background(military_background_params)

    if @military_background.save
      render json: {
        success: true,
        message: 'Military background created successfully',
        data: {
          military_background: military_background_data(@military_background)
        }
      }, status: :created
    else
      render json: {
        success: false,
        message: 'Military background creation failed',
        errors: @military_background.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @military_background.update(military_background_params)
      render json: {
        success: true,
        message: 'Military background updated successfully',
        data: {
          military_background: military_background_data(@military_background)
        }
      }
    else
      render json: {
        success: false,
        message: 'Military background update failed',
        errors: @military_background.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @military_background.destroy
    render json: {
      success: true,
      message: 'Military background deleted successfully'
    }
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_military_background
    @military_background = @user.military_background
  end

  def ensure_owner_or_admin
    unless @user == current_user || current_user.admin?
      render json: {
        success: false,
        message: 'Access denied'
      }, status: :forbidden
    end
  end

  def military_background_params
    params.require(:military_background).permit(
      :military_relationship, :branch_of_service, :rank, :mos_specialty,
      :service_start_date, :service_end_date, :additional_info
    )
  end

  def military_background_data(military_background)
    {
      id: military_background.id,
      military_relationship: military_background.military_relationship,
      branch_of_service: military_background.branch_of_service,
      rank: military_background.rank,
      mos_specialty: military_background.mos_specialty,
      service_start_date: military_background.service_start_date,
      service_end_date: military_background.service_end_date,
      additional_info: military_background.additional_info,
      verified: military_background.verified?,
      service_duration: military_background.service_duration,
      currently_serving: military_background.currently_serving?,
      created_at: military_background.created_at,
      updated_at: military_background.updated_at
    }
  end
end