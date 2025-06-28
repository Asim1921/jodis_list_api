# app/services/veteran_directory_scraper.rb
class VeteranDirectoryScraper
  include HTTParty
  
  attr_reader :results, :errors, :stats
  
  def initialize
    @results = []
    @errors = []
    @stats = {
      total_found: 0,
      successfully_imported: 0,
      duplicates_skipped: 0,
      errors_count: 0
    }
  end
  
  # Main scraping method
  def scrape_veteran_businesses(options = {})
    Rails.logger.info "Starting veteran business directory scraping..."
    
    begin
      # Scrape from VeteranOwnedBusiness.com
      scrape_veteran_owned_business_com(options)
      
      # Could add more sources here
      # scrape_other_veteran_directories(options)
      
      generate_report
    rescue => e
      Rails.logger.error "Scraping failed: #{e.message}"
      @errors << "General scraping error: #{e.message}"
    end
    
    self
  end
  
  private
  
  def scrape_veteran_owned_business_com(options = {})
    base_url = 'https://www.veteranownedbusiness.com'
    states = options[:states] || get_all_states
    
    states.each do |state|
      begin
        Rails.logger.info "Scraping businesses for #{state}..."
        scrape_state_businesses(base_url, state)
        
        # Add delay to be respectful to the server
        sleep(1)
        
      rescue => e
        Rails.logger.error "Error scraping #{state}: #{e.message}"
        @errors << "#{state}: #{e.message}"
        next
      end
    end
  end
  
  def scrape_state_businesses(base_url, state)
    # This is a conceptual implementation - actual scraping would need
    # to be adapted based on the website's structure
    
    url = "#{base_url}/?mode=geo&state=#{state}"
    response = HTTParty.get(url, {
      headers: {
        'User-Agent' => 'Mozilla/5.0 (compatible; JodisListBot/1.0)',
        'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
      },
      timeout: 30
    })
    
    return unless response.success?
    
    # Parse HTML content
    doc = Nokogiri::HTML(response.body)
    
    # Extract business listings (this would need to be customized based on actual HTML structure)
    business_elements = doc.css('.business-listing, .company-info, [data-business]')
    
    business_elements.each do |element|
      begin
        business_data = extract_business_data(element, state)
        process_business_data(business_data) if business_data
        @stats[:total_found] += 1
      rescue => e
        Rails.logger.error "Error processing business element: #{e.message}"
        @stats[:errors_count] += 1
      end
    end
  end
  
  def extract_business_data(element, state)
    # Extract business information from HTML element
    # This is a template - actual implementation depends on website structure
    
    business_name = extract_text(element, '.business-name, .company-name, h3, h4')
    return nil if business_name.blank?
    
    {
      business_name: clean_text(business_name),
      description: extract_text(element, '.description, .about, .summary'),
      business_phone: extract_phone(element),
      business_email: extract_email(element),
      website_url: extract_website(element),
      address_line1: extract_text(element, '.address, .street'),
      city: extract_text(element, '.city'),
      state: state,
      zip_code: extract_text(element, '.zip, .zipcode, .postal-code'),
      areas_served: extract_text(element, '.service-areas, .areas-served'),
      categories: extract_categories(element),
      military_verified: true, # Since it's from a veteran directory
      source_url: extract_source_url(element),
      scraped_at: Time.current
    }
  end
  
  def process_business_data(data)
    # Check if business already exists
    existing_business = find_existing_business(data)
    
    if existing_business
      @stats[:duplicates_skipped] += 1
      Rails.logger.info "Skipping duplicate: #{data[:business_name]}"
      return
    end
    
    # Create or find user for the business
    user = create_business_user(data)
    return unless user
    
    # Create business record
    business = create_business_record(user, data)
    
    if business&.persisted?
      @stats[:successfully_imported] += 1
      @results << {
        business_id: business.id,
        business_name: business.business_name,
        status: business.business_status,
        source: 'VeteranOwnedBusiness.com'
      }
      Rails.logger.info "Successfully imported: #{business.business_name}"
    else
      @stats[:errors_count] += 1
      @errors << "Failed to create business: #{data[:business_name]} - #{business&.errors&.full_messages&.join(', ')}"
    end
  end
  
  def find_existing_business(data)
    # Check for duplicates based on business name and location
    Business.where(
      "LOWER(business_name) = ? AND (city = ? OR business_phone = ?)",
      data[:business_name].downcase,
      data[:city],
      data[:business_phone]
    ).first
  end
  
  def create_business_user(data)
    # Create a temporary email if none provided
    email = data[:business_email].presence || generate_temp_email(data[:business_name])
    
    # Check if user already exists
    user = User.find_by(email: email)
    return user if user
    
    # Extract name from business name or use default
    first_name, last_name = extract_owner_name(data[:business_name])
    
    User.create!(
      email: email,
      first_name: first_name,
      last_name: last_name,
      phone: data[:business_phone],
      password: SecureRandom.hex(12),
      role: :business_owner,
      membership_status: :veteran # Since from veteran directory
    )
  rescue => e
    Rails.logger.error "Failed to create user for #{data[:business_name]}: #{e.message}"
    nil
  end
  
  def create_business_record(user, data)
    business = user.build_business(
      business_name: data[:business_name],
      description: data[:description],
      business_phone: data[:business_phone],
      business_email: data[:business_email],
      website_url: data[:website_url],
      address_line1: data[:address_line1],
      city: data[:city],
      state: data[:state],
      zip_code: data[:zip_code],
      areas_served: data[:areas_served],
      business_status: :pending, # Imported businesses start as pending
      meta_description: "Veteran-owned business imported from directory",
      admin_notes: "Imported from #{data[:source_url]} on #{data[:scraped_at]}"
    )
    
    if business.save
      # Assign categories if any were found
      assign_business_categories(business, data[:categories]) if data[:categories].present?
      
      # Create military background for the user
      create_military_background(user)
      
      # Geocode the address
      geocode_business_async(business)
    end
    
    business
  end
  
  def assign_business_categories(business, category_names)
    category_names.each do |category_name|
      category = find_or_create_category(category_name)
      business.business_categories << category if category && !business.business_categories.include?(category)
    end
  end
  
  def find_or_create_category(name)
    # Try to find existing category by name
    category = BusinessCategory.find_by("LOWER(name) = ?", name.downcase)
    return category if category
    
    # Create new category if it doesn't exist
    BusinessCategory.create(
      name: name.titleize,
      description: "Category automatically created during import",
      active: true
    )
  rescue => e
    Rails.logger.error "Failed to create category #{name}: #{e.message}"
    nil
  end
  
  def create_military_background(user)
    return if user.military_background.present?
    
    user.create_military_background!(
      military_relationship: :veteran,
      verified: false, # Will need manual verification
      additional_info: "Veteran status imported from veteran business directory"
    )
  rescue => e
    Rails.logger.error "Failed to create military background for user #{user.id}: #{e.message}"
  end
  
  def geocode_business_async(business)
    # Queue geocoding job to run asynchronously
    GeocodingJob.perform_later(business.id)
  end
  
  # Helper methods for data extraction
  def extract_text(element, selectors)
    selectors.split(', ').each do |selector|
      found = element.at_css(selector.strip)
      return found.text.strip if found
    end
    nil
  end
  
  def extract_phone(element)
    # Look for phone numbers in various formats
    phone_selectors = ['.phone', '.tel', '.telephone', '[href^="tel:"]', '.contact-phone']
    
    phone_selectors.each do |selector|
      found = element.at_css(selector)
      next unless found
      
      phone_text = found.text.strip
      phone_text = found['href'].gsub('tel:', '') if found['href']&.start_with?('tel:')
      
      # Clean and validate phone number
      cleaned_phone = phone_text.gsub(/[^\d\+\-\(\)\s]/, '')
      return cleaned_phone if cleaned_phone.match?(/[\d\-\(\)\s\+]{10,}/)
    end
    
    # Fallback: search for phone patterns in any text
    all_text = element.text
    phone_match = all_text.match(/(\+?1?[-.\s]?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4})/)
    phone_match ? phone_match[1].strip : nil
  end
  
  def extract_email(element)
    # Look for email addresses
    email_selectors = ['.email', '[href^="mailto:"]', '.contact-email']
    
    email_selectors.each do |selector|
      found = element.at_css(selector)
      next unless found
      
      email_text = found.text.strip
      email_text = found['href'].gsub('mailto:', '') if found['href']&.start_with?('mailto:')
      
      return email_text if email_text.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
    end
    
    # Fallback: search for email patterns in text
    all_text = element.text
    email_match = all_text.match(/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/)
    email_match ? email_match[0] : nil
  end
  
  def extract_website(element)
    # Look for website links
    link_selectors = ['a[href^="http"]', '.website', '.url', '.link']
    
    link_selectors.each do |selector|
      found = element.at_css(selector)
      next unless found
      
      url = found['href'] || found.text.strip
      return url if url.match?(/\Ahttps?:\/\//)
    end
    
    nil
  end
  
  def extract_categories(element)
    # Look for category/service information
    category_selectors = ['.categories', '.services', '.specialties', '.industry']
    categories = []
    
    category_selectors.each do |selector|
      found = element.at_css(selector)
      next unless found
      
      category_text = found.text.strip
      # Split on common delimiters
      categories.concat(category_text.split(/[,;|&]/).map(&:strip))
    end
    
    # Clean and filter categories
    categories.map(&:titleize).uniq.reject(&:blank?).first(5) # Limit to 5 categories
  end
  
  def extract_source_url(element)
    # Try to find a link to the original listing
    link = element.at_css('a')
    return link['href'] if link && link['href']
    
    # Fallback to a generic URL
    'https://www.veteranownedbusiness.com'
  end
  
  def clean_text(text)
    return nil if text.blank?
    
    # Remove extra whitespace and clean up text
    text.strip.gsub(/\s+/, ' ').gsub(/[^\w\s\-\.\,\&]/, '')
  end
  
  def generate_temp_email(business_name)
    # Generate a temporary email based on business name
    clean_name = business_name.downcase.gsub(/[^\w]/, '')
    "#{clean_name.first(20)}+imported@jodislist.com"
  end
  
  def extract_owner_name(business_name)
    # Try to extract owner name from business name
    # This is a simple heuristic - could be improved
    
    words = business_name.split
    
    # Look for common business suffixes
    business_suffixes = %w[LLC Inc Corp Company Co Services Solutions Group]
    name_words = words.reject { |word| business_suffixes.include?(word.gsub(/[^\w]/, '')) }
    
    if name_words.length >= 2
      [name_words.first, name_words.last]
    else
      [name_words.first || 'Business', 'Owner']
    end
  end
  
  def get_all_states
    %w[
      AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD
      MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC
      SD TN TX UT VT VA WA WV WI WY DC
    ]
  end
  
  def generate_report
    Rails.logger.info "Scraping completed. Report:"
    Rails.logger.info "Total found: #{@stats[:total_found]}"
    Rails.logger.info "Successfully imported: #{@stats[:successfully_imported]}"
    Rails.logger.info "Duplicates skipped: #{@stats[:duplicates_skipped]}"
    Rails.logger.info "Errors: #{@stats[:errors_count]}"
    
    if @errors.any?
      Rails.logger.error "Errors encountered:"
      @errors.each { |error| Rails.logger.error "  - #{error}" }
    end
    
    # Send notification to admins
    AdminNotificationMailer.scraping_report(@stats, @errors).deliver_later
  end
end