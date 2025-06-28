# db/migrate/20250628140000_enable_database_extensions.rb
class EnableDatabaseExtensions < ActiveRecord::Migration[8.0]
  def up
    # Enable cube extension (required for earthdistance)
    enable_extension 'cube' unless extension_enabled?('cube')
    
    # Enable earthdistance extension for location-based queries
    enable_extension 'earthdistance' unless extension_enabled?('earthdistance')
    
    puts "Database extensions enabled successfully!"
    puts "- cube: #{extension_enabled?('cube') ? 'enabled' : 'failed'}"
    puts "- earthdistance: #{extension_enabled?('earthdistance') ? 'enabled' : 'failed'}"
  end

  def down
    disable_extension 'earthdistance' if extension_enabled?('earthdistance')
    disable_extension 'cube' if extension_enabled?('cube')
  end
end