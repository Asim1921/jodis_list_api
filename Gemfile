# Gemfile - Updated for Rails 8 compatibility
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.4'

# Core Rails gems - Updated to Rails 8
gem 'rails', '~> 8.0.0'
gem 'pg', '~> 1.1'
gem 'puma', '>= 5.0'
gem 'bootsnap', '>= 1.4.4', require: false

# Authentication & Authorization
gem 'devise'
# gem 'devise-jwt'
gem 'jwt'

# API & CORS
gem 'rack-cors'
gem 'jsonapi-serializer'

# File handling & Image processing
gem 'image_processing', '~> 1.2'
gem 'active_storage_validations'

# Search & Pagination
gem 'ransack'
gem 'kaminari'

# Validation & Utilities
gem 'validates_email_format_of'
gem 'phonelib'

# Background jobs
gem 'sidekiq'

# Rails 8 specific gems
gem 'solid_cache'
gem 'solid_queue'
gem 'solid_cable'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'shoulda-matchers'
  gem 'database_cleaner-active_record'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'spring'
  gem 'annotate'
  gem 'bullet'
end

# Windows-specific
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]