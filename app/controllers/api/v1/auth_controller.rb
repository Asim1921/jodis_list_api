# app/controllers/api/v1/auth_controller.rb
class Api::V1::AuthController < Api::V1::BaseController
  skip_before_action :authenticate_user!, except: [:me, :logout]

  def login
    user = User.find_by(email: params[:email]&.downcase)

    if user&.valid_password?(params[:password])
      if user.active?
        token = JwtService.encode(user_id: user.id)
        render json: {
          success: true,
          message: 'Login successful',
          data: {
            user: user_data(user),
            token: token
          }
        }, status: :ok
      else
        render json: {
          success: false,
          message: 'Account is inactive. Please contact support.'
        }, status: :unauthorized
      end
    else
      render json: {
        success: false,
        message: 'Invalid email or password'
      }, status: :unauthorized
    end
  end

  def register
    user = User.new(user_params)
    
    if user.save
      token = JwtService.encode(user_id: user.id)
      render json: {
        success: true,
        message: 'Registration successful',
        data: {
          user: user_data(user),
          token: token
        }
      }, status: :created
    else
      render json: {
        success: false,
        message: 'Registration failed',
        errors: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def me
    render json: {
      success: true,
      data: {
        user: user_data(current_user)
      }
    }, status: :ok
  end

  def logout
    render json: {
      success: true,
      message: 'Logged out successfully'
    }, status: :ok
  end

  def forgot_password
    user = User.find_by(email: params[:email]&.downcase)
    
    if user
      user.send_reset_password_instructions
      render json: {
        success: true,
        message: 'Password reset instructions sent to your email'
      }, status: :ok
    else
      render json: {
        success: false,
        message: 'Email not found'
      }, status: :not_found
    end
  end

  def reset_password
    user = User.reset_password_by_token(reset_password_params)
    
    if user.errors.empty?
      render json: {
        success: true,
        message: 'Password reset successfully'
      }, status: :ok
    else
      render json: {
        success: false,
        message: 'Password reset failed',
        errors: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :email, :password, :password_confirmation,
      :first_name, :last_name, :phone, :role, :membership_status
    )
  end

  def reset_password_params
    params.require(:user).permit(:reset_password_token, :password, :password_confirmation)
  end

  def user_data(user)
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      full_name: user.full_name,
      phone: user.phone,
      role: user.role,
      membership_status: user.membership_status,
      has_business: user.has_business?,
      military_verified: user.military_verified?,
      avatar_url: user.avatar.attached? ? url_for(user.avatar) : nil,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
  end
end