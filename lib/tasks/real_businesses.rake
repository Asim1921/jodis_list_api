# lib/tasks/real_businesses.rake
namespace :db do
  namespace :seed do
    desc "Import real business data and clear dummy data"
    task real_businesses: :environment do
      puts "🚀 Starting real business data import..."
      puts "This will:"
      puts "  1. Clear all existing business data"
      puts "  2. Remove dummy business owners (keeping admin)"
      puts "  3. Import real veteran business data"
      puts "  4. Create sample reviews for each business"
      puts ""
      
      print "Are you sure you want to continue? (y/N): "
      response = STDIN.gets.chomp.downcase
      
      unless response == 'y' || response == 'yes'
        puts "❌ Import cancelled"
        exit
      end
      
      # Load the seed file
      load Rails.root.join('db', 'seeds_real_businesses.rb')
      
      puts "\n🎉 Real business import completed successfully!"
    end
    
    desc "Import additional real businesses from CSV file"
    task :import_csv, [:file_path] => :environment do |task, args|
      file_path = args[:file_path] || Rails.root.join('db', 'real_businesses.csv')
      
      unless File.exist?(file_path)
        puts "❌ CSV file not found: #{file_path}"
        puts "Please provide the correct path: rake db:seed:import_csv[/path/to/file.csv]"
        exit
      end
      
      puts "📊 Importing businesses from CSV: #{file_path}"
      
      require 'csv'
      
      CSV.foreach(file_path, headers: true) do |row|
        next if row['Company Name'].blank?
        
        puts "Processing: #{row['Company Name']}"
        
        begin
          # Create user for business owner
          poc_email = row['POC email'].presence || 
                     row['company email'].presence ||
                     "#{row['POC first name']&.downcase}.#{row['POC last name']&.downcase}@#{row['Company Name']&.gsub(/\s+/, '')&.downcase}.com"
          
          user = User.find_or_create_by(email: poc_email) do |u|
            u.first_name = row['POC first name'] || "Business"
            u.last_name = row['POC last name'] || "Owner"
            u.phone = row['POC phone']
            u.role = :business_owner
            u.membership_status = :veteran
            u.password = SecureRandom.hex(12)
            u.confirmed_at = Time.current
          end
          
          # Create military background if available
          if row['military background'].present?
            military_relationship = case row['military background'].downcase
                                  when /retired/, /separated/ then :veteran
                                  when /active/ then :active_duty
                                  when /guard/ then :national_guard
                                  when /reserve/ then :reserves
                                  else :veteran
                                  end
            
            branch = case row['military background'].downcase
                    when /army/ then "Army"
                    when /navy/ then "Navy"
                    when /marine/ then "Marines"
                    when /air force/ then "Air Force"
                    when /coast guard/ then "Coast Guard"
                    when /guard/ then "National Guard"
                    else "Unknown"
                    end
            
            user.create_military_background!(
              military_relationship: military_relationship,
              branch_of_service: branch,
              verified: true,
              additional_info: row['military background']
            ) unless user.military_background.present?
          end
          
          # Normalize state code
          state_code = case row['company state']&.strip
                      when 'Alabama' then 'AL'
                      when 'Alaska' then 'AK'
                      when 'Arizona' then 'AZ'
                      when 'Arkansas' then 'AR'
                      when 'California' then 'CA'
                      when 'Colorado' then 'CO'
                      when 'Connecticut' then 'CT'
                      when 'Delaware' then 'DE'
                      when 'Florida' then 'FL'
                      when 'Georgia' then 'GA'
                      when 'Hawaii' then 'HI'
                      when 'Idaho' then 'ID'
                      when 'Illinois' then 'IL'
                      when 'Indiana' then 'IN'
                      when 'Iowa' then 'IA'
                      when 'Kansas' then 'KS'
                      when 'Kentucky' then 'KY'
                      when 'Louisiana' then 'LA'
                      when 'Maine' then 'ME'
                      when 'Maryland' then 'MD'
                      when 'Massachusetts' then 'MA'
                      when 'Michigan' then 'MI'
                      when 'Minnesota' then 'MN'
                      when 'Mississippi' then 'MS'
                      when 'Missouri' then 'MO'
                      when 'Montana' then 'MT'
                      when 'Nebraska' then 'NE'
                      when 'Nevada' then 'NV'
                      when 'New Hampshire' then 'NH'
                      when 'New Jersey' then 'NJ'
                      when 'New Mexico' then 'NM'
                      when 'New York' then 'NY'
                      when 'North Carolina' then 'NC'
                      when 'North Dakota' then 'ND'
                      when 'Ohio' then 'OH'
                      when 'Oklahoma' then 'OK'
                      when 'Oregon' then 'OR'
                      when 'Pennsylvania' then 'PA'
                      when 'Rhode Island' then 'RI'
                      when 'South Carolina' then 'SC'
                      when 'South Dakota' then 'SD'
                      when 'Tennessee' then 'TN'
                      when 'Texas' then 'TX'
                      when 'Utah' then 'UT'
                      when 'Vermont' then 'VT'
                      when 'Virginia' then 'VA'
                      when 'Washington' then 'WA'
                      when 'West Virginia' then 'WV'
                      when 'Wisconsin' then 'WI'
                      when 'Wyoming' then 'WY'
                      when 'District of Columbia' then 'DC'
                      else row['company state']&.strip
                      end
          
          # Parse employee count
          employee_count = case row['# of employees']&.strip
                          when '1' then 1
                          when '2' then 2
                          when '2-10' then 5
                          when '11-50' then 25
                          when '51-200' then 100
                          else nil
                          end
          
          # Create business
          business = user.create_business!(
            business_name: row['Company Name'],
            description: row['company write up'],
            business_phone: row['company phone'],
            business_email: row['company email'],
            website_url: row['company website url'],
            address_line1: row['company address'],
            city: row['company city'],
            state: state_code,
            zip_code: row['company zip code'],
            areas_served: row['company service area'].presence || "#{row['company city']}, #{state_code}",
            employee_count: employee_count,
            emergency_service: row['company category 1']&.downcase&.include?('fire') || 
                              row['company category 2']&.downcase&.include?('fire') ||
                              row['company category 1']&.downcase&.include?('emergency'),
            insured: true,
            verified: true,
            business_status: :approved,
            featured: rand < 0.3, # 30% chance of being featured
            social_media_links: {
              facebook: row['company Facebook'].presence,
              instagram: row['company Instagram'].presence,
              linkedin: row['company LinkedIn'].presence,
              youtube: row['company YouTube'].presence
            }.compact,
            admin_notes: "Imported from CSV file on #{Date.current}",
            meta_description: row['company write up']&.truncate(160)
          )
          
          # Find or create categories
          categories = []
          [row['company category 1'], row['company category 2']].compact.each do |category_name|
            next if category_name.blank?
            
            category = BusinessCategory.find_or_create_by(name: category_name.titleize) do |cat|
              cat.description = "Professional #{category_name.downcase} services"
              cat.icon_class = "fas fa-briefcase"
              cat.active = true
              cat.sort_order = 200
            end
            categories << category
          end
          
          business.business_categories = categories
          
          puts "  ✅ Created: #{business.business_name}"
          
        rescue => e
          puts "  ❌ Error: #{e.message}"
        end
      end
      
      puts "\n✅ CSV import completed!"
    end
  end
  
  desc "Reset database with real business data"
  task reset_with_real_data: :environment do |task|
    puts "🔄 Resetting database with real business data..."
    
    # Reset database
    Rake::Task['db:reset'].invoke
    
    # Run real business seed
    Rake::Task['db:seed:real_businesses'].invoke
  end
end