# db/seeds.rb - Enhanced for Module 2

# Helper methods for generating test data
def generate_random_lat
  # Random latitude within Texas bounds
  rand(25.8..36.5)
end

def generate_random_lng
  # Random longitude within Texas bounds
  rand(-106.6..-93.5)
end

puts "🌱 Seeding database for Jodi's List Module 2..."

# Business Categories
puts "Creating business categories..."

categories_data = [
  {
    name: "Home Services",
    description: "General home improvement and maintenance services",
    icon_class: "fas fa-home",
    color_code: "#3B82F6",
    children: [
      { name: "Plumbing", description: "Plumbing installation and repair", icon_class: "fas fa-wrench", requires_license: true },
      { name: "Electrical", description: "Electrical installation and repair", icon_class: "fas fa-bolt", requires_license: true },
      { name: "HVAC", description: "Heating, ventilation, and air conditioning", icon_class: "fas fa-fan", requires_license: true },
      { name: "Roofing", description: "Roof installation and repair", icon_class: "fas fa-building", requires_license: true },
      { name: "Landscaping", description: "Lawn care and landscape design", icon_class: "fas fa-leaf" },
      { name: "Cleaning Services", description: "Home and office cleaning", icon_class: "fas fa-broom" },
      { name: "Handyman", description: "General home repairs and maintenance", icon_class: "fas fa-tools" },
      { name: "Painting", description: "Interior and exterior painting", icon_class: "fas fa-paint-roller" },
      { name: "Flooring", description: "Floor installation and refinishing", icon_class: "fas fa-layer-group" },
      { name: "Windows & Doors", description: "Window and door installation", icon_class: "fas fa-door-open" }
    ]
  },
  {
    name: "Professional Services",
    description: "Business and professional service providers",
    icon_class: "fas fa-briefcase",
    color_code: "#10B981",
    children: [
      { name: "Legal Services", description: "Legal consultation and representation", icon_class: "fas fa-gavel", requires_license: true },
      { name: "Accounting", description: "Accounting and tax services", icon_class: "fas fa-calculator", requires_license: true },
      { name: "Real Estate", description: "Real estate sales and services", icon_class: "fas fa-house-user", requires_license: true },
      { name: "Insurance", description: "Insurance sales and consultation", icon_class: "fas fa-shield-alt", requires_license: true },
      { name: "Financial Planning", description: "Financial advisory services", icon_class: "fas fa-chart-line", requires_license: true },
      { name: "Marketing", description: "Marketing and advertising services", icon_class: "fas fa-megaphone" },
      { name: "Web Development", description: "Website design and development", icon_class: "fas fa-code" },
      { name: "Consulting", description: "Business consulting services", icon_class: "fas fa-user-tie" }
    ]
  },
  {
    name: "Automotive",
    description: "Vehicle-related services and repairs",
    icon_class: "fas fa-car",
    color_code: "#F59E0B",
    children: [
      { name: "Auto Repair", description: "Vehicle maintenance and repair", icon_class: "fas fa-wrench" },
      { name: "Auto Detailing", description: "Vehicle cleaning and detailing", icon_class: "fas fa-spray-can" },
      { name: "Towing", description: "Vehicle towing and roadside assistance", icon_class: "fas fa-truck", emergency_service: true },
      { name: "Auto Sales", description: "Vehicle sales and leasing", icon_class: "fas fa-car-side" },
      { name: "Auto Parts", description: "Automotive parts and accessories", icon_class: "fas fa-cog" }
    ]
  },
  {
    name: "Health & Wellness",
    description: "Health, fitness, and wellness services",
    icon_class: "fas fa-heart",
    color_code: "#EF4444",
    children: [
      { name: "Personal Training", description: "Fitness and personal training", icon_class: "fas fa-dumbbell" },
      { name: "Massage Therapy", description: "Therapeutic massage services", icon_class: "fas fa-hand-holding-heart", requires_license: true },
      { name: "Mental Health", description: "Counseling and therapy services", icon_class: "fas fa-brain", requires_license: true },
      { name: "Nutrition", description: "Nutritional counseling and planning", icon_class: "fas fa-apple-alt" },
      { name: "Healthcare", description: "Medical and healthcare services", icon_class: "fas fa-stethoscope", requires_license: true }
    ]
  },
  {
    name: "Emergency Services",
    description: "Emergency and urgent service providers",
    icon_class: "fas fa-exclamation-triangle",
    color_code: "#DC2626",
    emergency_service: true,
    children: [
      { name: "Locksmith", description: "Lock installation and emergency lockout", icon_class: "fas fa-key", emergency_service: true },
      { name: "Emergency Plumbing", description: "24/7 plumbing emergencies", icon_class: "fas fa-water", emergency_service: true, requires_license: true },
      { name: "Emergency Electrical", description: "Electrical emergency services", icon_class: "fas fa-bolt", emergency_service: true, requires_license: true },
      { name: "Water Damage", description: "Water damage restoration", icon_class: "fas fa-tint", emergency_service: true },
      { name: "Security Services", description: "Security installation and monitoring", icon_class: "fas fa-shield-alt" }
    ]
  },
  {
    name: "Technology",
    description: "Technology services and support",
    icon_class: "fas fa-laptop",
    color_code: "#8B5CF6",
    children: [
      { name: "IT Support", description: "Computer and network support", icon_class: "fas fa-desktop" },
      { name: "Software Development", description: "Custom software development", icon_class: "fas fa-code" },
      { name: "Cybersecurity", description: "Security consulting and services", icon_class: "fas fa-lock" },
      { name: "Data Recovery", description: "Data backup and recovery services", icon_class: "fas fa-database" }
    ]
  },
  {
    name: "Construction",
    description: "Construction and contracting services",
    icon_class: "fas fa-hard-hat",
    color_code: "#F97316",
    children: [
      { name: "General Contracting", description: "General construction services", icon_class: "fas fa-hammer", requires_license: true },
      { name: "Kitchen Remodeling", description: "Kitchen renovation and remodeling", icon_class: "fas fa-utensils" },
      { name: "Bathroom Remodeling", description: "Bathroom renovation services", icon_class: "fas fa-bath" },
      { name: "Concrete", description: "Concrete work and installation", icon_class: "fas fa-building" },
      { name: "Fencing", description: "Fence installation and repair", icon_class: "fas fa-border-all" }
    ]
  },
  {
    name: "Personal Services",
    description: "Personal care and lifestyle services",
    icon_class: "fas fa-user",
    color_code: "#EC4899",
    children: [
      { name: "Pet Services", description: "Pet care and veterinary services", icon_class: "fas fa-paw" },
      { name: "Tutoring", description: "Educational tutoring services", icon_class: "fas fa-graduation-cap" },
      { name: "Event Planning", description: "Event planning and coordination", icon_class: "fas fa-calendar-alt" },
      { name: "Photography", description: "Professional photography services", icon_class: "fas fa-camera" },
      { name: "Personal Chef", description: "Personal cooking and catering", icon_class: "fas fa-utensils" }
    ]
  }
]

def create_category_tree(categories_data, parent = nil)
  categories_data.each do |cat_data|
    category = BusinessCategory.create!(
      name: cat_data[:name],
      description: cat_data[:description],
      icon_class: cat_data[:icon_class],
      color_code: cat_data[:color_code],
      parent_id: parent&.id,
      level: parent ? parent.level + 1 : 0,
      requires_license: cat_data[:requires_license] || false,
      emergency_service: cat_data[:emergency_service] || false,
      active: true,
      slug: cat_data[:name].parameterize,
      keywords: cat_data[:name].split + (cat_data[:description]&.split || [])
    )
    
    puts "  ✓ Created category: #{category.name}"
    
    # Create child categories
    if cat_data[:children]
      create_category_tree(cat_data[:children], category)
    end
  end
end

create_category_tree(categories_data)

puts "✓ Created #{BusinessCategory.count} business categories"

# Sample Admin User
puts "\nCreating admin user..."
admin = User.create!(
  email: 'admin@jodislist.com',
  password: 'AdminPass123!',
  first_name: 'Admin',
  last_name: 'User',
  phone: '15550100',
  role: :admin,
  membership_status: :member,
  confirmed_at: Time.current
)
puts "✓ Created admin user: #{admin.email}"

# Sample Business Owners with Military Backgrounds
puts "\nCreating sample veteran business owners..."

# Create John Smith - Plumber
john = User.create!(
  email: 'john.smith@email.com',
  password: 'VetPass123!',
  first_name: 'John',
  last_name: 'Smith',
  phone: '15550101',
  role: :business_owner,
  membership_status: :veteran,
  confirmed_at: Time.current
)

john.create_military_background!(
  military_relationship: :veteran, 
  branch_of_service: 'Army', 
  rank: 'Sergeant', 
  mos_specialty: '12B Combat Engineer',
  service_start_date: Date.new(2005, 3, 15),
  service_end_date: Date.new(2015, 3, 14),
  additional_info: 'Served in Iraq and Afghanistan. Purple Heart recipient.',
  verified: true 
)

puts "  ✓ Created veteran user: #{john.full_name}"

# Create Maria Garcia - Lawyer
maria = User.create!(
  email: 'maria.garcia@email.com',
  password: 'VetPass123!',
  first_name: 'Maria',
  last_name: 'Garcia',
  phone: '15550102',
  role: :business_owner,
  membership_status: :veteran,
  confirmed_at: Time.current
)

maria.create_military_background!(
  military_relationship: :veteran, 
  branch_of_service: 'Navy', 
  rank: 'Petty Officer First Class', 
  mos_specialty: 'YN1 Yeoman',
  service_start_date: Date.new(2008, 7, 20),
  service_end_date: Date.new(2018, 7, 19),
  additional_info: 'Naval Legal Service Office. Expert in military law.',
  verified: true 
)

puts "  ✓ Created veteran user: #{maria.full_name}"

# Create Robert Johnson - HVAC
robert = User.create!(
  email: 'robert.johnson@email.com',
  password: 'VetPass123!',
  first_name: 'Robert',
  last_name: 'Johnson',
  phone: '15550103',
  role: :business_owner,
  membership_status: :veteran,
  confirmed_at: Time.current
)

robert.create_military_background!(
  military_relationship: :veteran, 
  branch_of_service: 'Air Force', 
  rank: 'Staff Sergeant', 
  mos_specialty: '3E1X1 Heating, Ventilation, AC and Refrigeration',
  service_start_date: Date.new(2010, 1, 12),
  service_end_date: Date.new(2020, 1, 11),
  additional_info: 'HVAC specialist with extensive commercial and residential experience.',
  verified: true 
)

puts "  ✓ Created veteran user: #{robert.full_name}"

# Create Sarah Davis - Event Planner (Military Spouse)
sarah = User.create!(
  email: 'sarah.davis@email.com',
  password: 'VetPass123!',
  first_name: 'Sarah',
  last_name: 'Davis',
  phone: '15550104',
  role: :business_owner,
  membership_status: :spouse,
  confirmed_at: Time.current
)

sarah.create_military_background!(
  military_relationship: :supporter,
  additional_info: 'Military spouse, husband served 20 years active duty. Supports veteran community.',
  verified: true 
)

puts "  ✓ Created veteran user: #{sarah.full_name}"

# Create Michael Wilson - Security
michael = User.create!(
  email: 'michael.wilson@email.com',
  password: 'VetPass123!',
  first_name: 'Michael',
  last_name: 'Wilson',
  phone: '15550105',
  role: :business_owner,
  membership_status: :veteran,
  confirmed_at: Time.current
)

michael.create_military_background!(
  military_relationship: :veteran, 
  branch_of_service: 'Marines', 
  rank: 'Corporal', 
  mos_specialty: '5811 Military Police',
  service_start_date: Date.new(2015, 6, 8),
  service_end_date: Date.new(2021, 6, 7),
  additional_info: 'Security specialist with law enforcement training.',
  verified: true 
)

puts "  ✓ Created veteran user: #{michael.full_name}"

puts "✓ Created 5 veteran business owners"

# Sample Businesses
puts "\nCreating sample businesses..."

# Create John's Plumbing Business
johns_business = Business.create!(
  user: john,
  business_name: "Smith Plumbing Services",
  description: "Professional plumbing services with over 15 years of experience. Specializing in residential and commercial plumbing installations, repairs, and emergency services.",
  business_phone: "15551001",
  business_email: "info@smithplumbing.com",
  website_url: "https://smithplumbing.com",
  address_line1: "123 Main Street",
  city: "Austin",
  state: "TX",
  zip_code: "73301",
  areas_served: "Austin, Round Rock, Cedar Park, Georgetown",
  years_in_business: 15,
  employee_count: 8,
  insured: true,
  bonded: true,
  license_number: "TX-PLB-12345",
  business_status: :approved,
  featured: true,
  verified: true,
  business_hours: {
    "monday" => { "open" => "8:00 AM", "close" => "6:00 PM" },
    "tuesday" => { "open" => "8:00 AM", "close" => "6:00 PM" },
    "wednesday" => { "open" => "8:00 AM", "close" => "6:00 PM" },
    "thursday" => { "open" => "8:00 AM", "close" => "6:00 PM" },
    "friday" => { "open" => "8:00 AM", "close" => "6:00 PM" },
    "saturday" => { "open" => "9:00 AM", "close" => "4:00 PM" },
    "sunday" => { "closed" => true }
  },
  latitude: generate_random_lat,
  longitude: generate_random_lng
)

# Assign categories to John's business
plumbing_cat = BusinessCategory.find_by(name: "Plumbing")
emergency_plumbing_cat = BusinessCategory.find_by(name: "Emergency Plumbing")
johns_business.business_categories << plumbing_cat if plumbing_cat
johns_business.business_categories << emergency_plumbing_cat if emergency_plumbing_cat

puts "  ✓ Created business: #{johns_business.business_name}"

# Create Maria's Legal Business
marias_business = Business.create!(
  user: maria,
  business_name: "Garcia Legal Services",
  description: "Experienced legal representation for veterans and their families. Specializing in disability claims, family law, and business formation.",
  business_phone: "15551002",
  business_email: "maria@garcialegal.com",
  website_url: "https://garcialegal.com",
  address_line1: "456 Oak Avenue",
  city: "San Antonio",
  state: "TX",
  zip_code: "78201",
  areas_served: "San Antonio, New Braunfels, Seguin, Schertz",
  years_in_business: 12,
  employee_count: 4,
  insured: true,
  license_number: "TX-LAW-67890",
  business_status: :approved,
  featured: true,
  verified: true,
  latitude: generate_random_lat,
  longitude: generate_random_lng
)

legal_cat = BusinessCategory.find_by(name: "Legal Services")
marias_business.business_categories << legal_cat if legal_cat

puts "  ✓ Created business: #{marias_business.business_name}"

# Create Robert's HVAC Business
roberts_business = Business.create!(
  user: robert,
  business_name: "Johnson HVAC Solutions",
  description: "Reliable heating and cooling services for residential and commercial properties. Energy-efficient solutions and 24/7 emergency service.",
  business_phone: "15551003",
  business_email: "bob@johnsonhvac.com",
  website_url: "https://johnsonhvac.com",
  address_line1: "789 Pine Road",
  city: "Dallas",
  state: "TX",
  zip_code: "75201",
  areas_served: "Dallas, Plano, Frisco, Richardson, Garland",
  years_in_business: 10,
  employee_count: 12,
  insured: true,
  bonded: true,
  license_number: "TX-HVAC-11111",
  business_status: :approved,
  verified: true,
  emergency_service: true,
  latitude: generate_random_lat,
  longitude: generate_random_lng
)

hvac_cat = BusinessCategory.find_by(name: "HVAC")
roberts_business.business_categories << hvac_cat if hvac_cat

puts "  ✓ Created business: #{roberts_business.business_name}"

# Create Sarah's Event Planning Business
sarahs_business = Business.create!(
  user: sarah,
  business_name: "Davis Event Planning",
  description: "Creating memorable events for military families and organizations. Specializing in weddings, corporate events, and military ceremonies.",
  business_phone: "15551004",
  business_email: "sarah@daviseventplanning.com",
  website_url: "https://daviseventplanning.com",
  address_line1: "321 Cedar Lane",
  city: "Houston",
  state: "TX",
  zip_code: "77001",
  areas_served: "Houston, Sugar Land, Katy, The Woodlands",
  years_in_business: 8,
  employee_count: 6,
  insured: true,
  business_status: :approved,
  verified: true,
  latitude: generate_random_lat,
  longitude: generate_random_lng
)

event_cat = BusinessCategory.find_by(name: "Event Planning")
sarahs_business.business_categories << event_cat if event_cat

puts "  ✓ Created business: #{sarahs_business.business_name}"

# Create Michael's Security Business
michaels_business = Business.create!(
  user: michael,
  business_name: "Wilson Security Services",
  description: "Professional security services for residential and commercial properties. Veteran-owned and operated with military precision.",
  business_phone: "15551005",
  business_email: "mike@wilsonsecurity.com",
  website_url: "https://wilsonsecurity.com",
  address_line1: "654 Maple Drive",
  city: "Fort Worth",
  state: "TX",
  zip_code: "76101",
  areas_served: "Fort Worth, Arlington, Grand Prairie, Irving",
  years_in_business: 6,
  employee_count: 15,
  insured: true,
  bonded: true,
  license_number: "TX-SEC-22222",
  business_status: :approved,
  featured: true,
  verified: true,
  latitude: generate_random_lat,
  longitude: generate_random_lng
)

security_cat = BusinessCategory.find_by(name: "Security Services")
michaels_business.business_categories << security_cat if security_cat

puts "  ✓ Created business: #{michaels_business.business_name}"

created_businesses = [johns_business, marias_business, roberts_business, sarahs_business, michaels_business]

puts "✓ Created #{created_businesses.count} sample businesses"

# Sample Reviews
puts "\nCreating sample reviews..."

review_texts = [
  {
    title: "Excellent Service!",
    text: "Outstanding work and very professional. Highly recommend for any plumbing needs.",
    rating: 5
  },
  {
    title: "Great Experience",
    text: "Quick response time and fair pricing. Will definitely use again.",
    rating: 5
  },
  {
    title: "Professional and Reliable",
    text: "Very knowledgeable and got the job done right the first time.",
    rating: 4
  },
  {
    title: "Good Service",
    text: "Satisfied with the work. Minor delay but overall good experience.",
    rating: 4
  },
  {
    title: "Highly Recommended",
    text: "Excellent communication and quality work. Supporting veteran businesses!",
    rating: 5
  }
]

# Create sample customers
customer_users = []
5.times do |i|
  customer = User.create!(
    email: "customer#{i+1}@example.com",
    password: 'Customer123!',
    first_name: "Customer",
    last_name: "#{i+1}",
    phone: "1555020#{i+1}",
    role: :customer,
    membership_status: :supporter,
    confirmed_at: Time.current
  )
  customer_users << customer
end

puts "✓ Created #{customer_users.count} sample customers"

# Create reviews for each business
created_businesses.each do |business|
  # Create 2-4 reviews per business
  review_count = rand(2..4)
  review_count.times do |i|
    review_data = review_texts.sample
    customer = customer_users.sample
    
    # Skip if customer already reviewed this business
    next if business.reviews.exists?(user: customer)
    
    business.reviews.create!(
      user: customer,
      rating: review_data[:rating],
      review_title: review_data[:title],
      review_text: review_data[:text],
      verified_purchase: [true, false].sample,
      active: true,
      created_at: rand(6.months.ago..Time.current)
    )
  end
  
  puts "  ✓ Created reviews for: #{business.business_name}"
end

puts "✓ Created sample reviews"

# Sample Inquiries
puts "\nCreating sample inquiries..."

inquiry_messages = [
  {
    subject: "Service Quote Request",
    message: "Hi, I need a quote for kitchen plumbing installation. When would you be available?",
    preferred_contact_method: "phone"
  },
  {
    subject: "Emergency Service",
    message: "I have a water leak emergency. Can you come out today?",
    preferred_contact_method: "phone"
  },
  {
    subject: "General Information",
    message: "Do you offer maintenance contracts? I'd like to know more about your services.",
    preferred_contact_method: "email"
  },
  {
    subject: "Project Consultation",
    message: "I'm planning a home renovation. Could we schedule a consultation?",
    preferred_contact_method: "phone"
  }
]

created_businesses.each do |business|
  # Create 1-3 inquiries per business
  inquiry_count = rand(1..3)
  inquiry_count.times do |i|
    inquiry_data = inquiry_messages.sample
    customer = customer_users.sample
    
    inquiry = business.inquiries.create!(
      user: customer,
      subject: inquiry_data[:subject],
      message: inquiry_data[:message],
      contact_phone: customer.phone,
      preferred_contact_method: inquiry_data[:preferred_contact_method],
      status: [:pending, :in_progress, :responded, :closed].sample,
      created_at: rand(3.months.ago..Time.current)
    )
    
    # Sometimes add a business response for responded/closed inquiries
    if [:responded, :closed].include?(inquiry.status.to_sym)
      inquiry.update!(
        business_response: "Thank you for your inquiry! We'll get back to you within 24 hours.",
        responded_at: inquiry.created_at + rand(1..48).hours
      )
    end
  end
  
  puts "  ✓ Created inquiries for: #{business.business_name}"
end

puts "✓ Created sample inquiries"

# Create some pending businesses for admin testing
puts "\nCreating pending businesses for admin review..."
puts "✓ Skipping pending businesses for now (can be added via admin panel)"

puts "\n🎉 Module 2 seeding completed successfully!"
puts "\nSummary:"
puts "- #{BusinessCategory.count} business categories created"
puts "- #{User.where(role: :admin).count} admin user created"
puts "- #{User.where(role: :business_owner).count} business owners created"
puts "- #{User.where(role: :customer).count} customers created"
puts "- #{Business.count} businesses created"
puts "- #{Review.count} reviews created"
puts "- #{Inquiry.count} inquiries created"
puts "- #{MilitaryBackground.count} military backgrounds created"

puts "\nAdmin login: admin@jodislist.com / AdminPass123!"
puts "Sample veteran business owner: john.smith@email.com / VetPass123!"
puts "Sample customer: customer1@example.com / Customer123!"

puts "\n✅ Ready to test Module 2 features!"

# Update business coordinates using geocoding (if API key is available)
if ENV['GOOGLE_MAPS_API_KEY'].present?
  puts "\nGeocoding business addresses..."
  
  Business.where(latitude: nil).find_each do |business|
    next unless business.full_address.present?
    
    # Skip geocoding in seeds for now - can be done via background job
    puts "  ⏭ Skipping geocoding for: #{business.business_name} (run geocoding job separately)"
  end
  
  puts "✓ Geocoding setup ready (run separately)"
else
  puts "\nSkipping geocoding (Google Maps API key not configured in .env)"
end