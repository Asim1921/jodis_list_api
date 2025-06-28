# app/controllers/health_controller.rb
class HealthController < ApplicationController
  # Skip all authentication for health check
  skip_before_action :authenticate_user!, raise: false

  def check
    render json: {
      status: 'healthy',
      timestamp: Time.current.iso8601,
      version: '1.0.0',
      environment: Rails.env,
      database: database_status
    }
  end

  private

  def database_status
    ActiveRecord::Base.connection.execute('SELECT 1')
    'connected'
  rescue StandardError
    'disconnected'
  end
end