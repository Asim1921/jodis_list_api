# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  private

  def record_not_found(exception)
    render json: {
      success: false,
      message: 'Record not found',
      error: exception.message
    }, status: :not_found
  end

  def record_invalid(exception)
    render json: {
      success: false,
      message: 'Validation failed',
      errors: exception.record.errors.full_messages
    }, status: :unprocessable_entity
  end

  def parameter_missing(exception)
    render json: {
      success: false,
      message: 'Required parameter missing',
      error: exception.message
    }, status: :bad_request
  end
end