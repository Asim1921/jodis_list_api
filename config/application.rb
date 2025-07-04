# config/application.rb
require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"

# Add this line to explicitly require Devise
require 'devise'

Bundler.require(*Rails.groups)

module JodisListApi
  class Application < Rails::Application
    config.load_defaults 8.0
    config.api_only = true
  end
end