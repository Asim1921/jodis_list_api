# Gemfile
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.4'

# Core Rails gems
gem 'rails', '~> 7.0.0'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'bootsnap', '>= 1.4.4', require: false

# Authentication & Authorization
gem 'devise'
gem 'devise-jwt'
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

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'shoulda-matchers'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'spring'
  gem 'annotate'
  gem 'bullet'
end

# Windows-specific
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]