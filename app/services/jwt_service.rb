# app/services/jwt_service.rb
class JwtService
  SECRET_KEY = Rails.application.credentials.secret_key_base

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError => e
    Rails.logger.error("JWT Decode Error: #{e.message}")
    nil
  end

  def self.current_user(request)
    token = extract_token(request)
    return nil unless token

    decoded = decode(token)
    return nil unless decoded

    User.find_by(id: decoded[:user_id])
  rescue ActiveRecord::RecordNotFound
    nil
  end

  private

  def self.extract_token(request)
    auth_header = request.headers['Authorization']
    return nil unless auth_header

    auth_header.split(' ').last if auth_header.start_with?('Bearer ')
  end
end