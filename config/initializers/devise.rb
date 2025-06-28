# config/initializers/devise.rb
require 'devise'

Devise.setup do |config|
  # The secret key used by Devise
  config.secret_key = Rails.application.credentials.secret_key_base || 'your-secret-key-here'
  
  # ==> Mailer Configuration
  config.mailer_sender = 'noreply@jodislist.com'

  # ==> ORM configuration
  require 'devise/orm/active_record'

  # ==> Configuration for any authentication mechanism
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth, :params_auth]
  config.stretches = Rails.env.test? ? 1 : 12
  config.reconfirmable = true
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 6..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete
  
  # API-specific configuration
  config.navigational_formats = []
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other
end