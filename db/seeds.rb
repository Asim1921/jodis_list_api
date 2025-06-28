# db/seeds.rb
puts "🌱 Seeding database..."

# Create Admin User
admin = User.create!(
  email: 'admin@jodislist.com',
  password: 'Admin123!',
  password_confirmation: 'Admin123!',
  first_name: 'Admin',
  last_name: 'User',
  role: 'admin',
  membership_status: 'member',
  confirmed_at: Time.current
)

puts "✅ Created admin user: #{admin.email}"

# Create Business Categories
categories_data = [
  { name: 'Home Services', description: 'Handyman, cleaning, landscaping, pest control', icon_class: 'fas fa-home', sort_order: 1 },
  { name: 'Real Estate', description: 'Real estate agents, property management', icon_class: 'fas fa-building', sort_order: 2 },
  { name: 'Automotive', description: 'Auto repair, detailing, towing services', icon_class: 'fas fa-car', sort_order: 3 },
  { name: 'Health & Wellness', description: 'Fitness, therapy, medical services', icon_class: 'fas fa-heart', sort_order: 4 },
  { name: 'Technology', description: 'IT support, web development, cybersecurity', icon_class: 'fas fa-laptop', sort_order: 5 },
  { name: 'Construction', description: 'General contracting, electrical, plumbing', icon_class: 'fas fa-hard-hat', sort_order: 6 },
  { name: 'Legal Services', description: 'Attorneys, legal consulting, notary', icon_class: 'fas fa-gavel', sort_order: 7 },
  { name: 'Financial Services', description: 'Accounting, financial planning, insurance', icon_class: 'fas fa-dollar-sign', sort_order: 8 },
  { name: 'Education', description: 'Tutoring, training, educational consulting', icon_class: 'fas fa-graduation-cap', sort_order: 9 },
  { name: 'Food & Beverage', description: 'Catering, restaurants, food trucks', icon_class: 'fas fa-utensils', sort_order: 10 }
]

categories_data.each do |category_data|
  category = BusinessCategory.create!(category_data)
  puts "✅ Created category: #{category.name}"
end

# Create Sample Business Owner
business_owner = User.create!(
  email: 'business@example.com',
  password: 'Business123!',
  password_confirmation: 'Business123!',
  first_name: 'John',
  last_name: 'Smith',
  phone: '15550123456',  # Fixed phone format: country code + number
  role: 'business_owner',
  membership_status: 'veteran',
  confirmed_at: Time.current
)

# Create Military Background for Business Owner
military_background = MilitaryBackground.create!(
  user: business_owner,
  military_relationship: 'veteran',
  branch_of_service: 'Army',
  rank: 'Sergeant',
  mos_specialty: '11B Infantry',
  service_start_date: Date.new(2010, 6, 1),
  service_end_date: Date.new(2018, 5, 31),
  verified: true
)

puts "✅ Created business owner: #{business_owner.email} with military background"

# Create Sample Business
home_services_category = BusinessCategory.find_by(name: 'Home Services')
construction_category = BusinessCategory.find_by(name: 'Construction')

business = Business.create!(
  user: business_owner,
  business_name: 'Smith Home Services',
  description: 'Veteran-owned home services company specializing in handyman work, home repairs, and small construction projects. We provide reliable, high-quality service with military precision.',
  business_phone: '15550123456',  # Fixed phone format
  business_email: 'info@smithhomeservices.com',
  license_number: 'HS-12345',
  areas_served: 'Dallas-Fort Worth Metroplex, Texas',
  website_url: 'https://smithhomeservices.com',
  address_line1: '123 Main Street',
  city: 'Dallas',
  state: 'Texas',
  zip_code: '75201',
  country: 'United States',
  latitude: 32.7767,
  longitude: -96.7970,
  business_status: 'approved',
  featured: true,
  verified: true,
  business_hours: {
    monday: { open: '08:00', close: '17:00' },
    tuesday: { open: '08:00', close: '17:00' },
    wednesday: { open: '08:00', close: '17:00' },
    thursday: { open: '08:00', close: '17:00' },
    friday: { open: '08:00', close: '17:00' },
    saturday: { open: '09:00', close: '15:00' },
    sunday: { closed: true }
  },
  meta_title: 'Smith Home Services - Veteran-Owned Home Repair in Dallas',
  meta_description: 'Professional home services by a veteran-owned business in Dallas-Fort Worth. Handyman work, repairs, and construction with military-grade quality.'
)

# Associate business with categories
BusinessCategoryAssignment.create!(business: business, business_category: home_services_category)
BusinessCategoryAssignment.create!(business: business, business_category: construction_category)

puts "✅ Created sample business: #{business.business_name}"

# Create Sample Customer
customer = User.create!(
  email: 'customer@example.com',
  password: 'Customer123!',
  password_confirmation: 'Customer123!',
  first_name: 'Jane',
  last_name: 'Doe',
  phone: '15550456789',  # Fixed phone format
  role: 'customer',
  membership_status: 'member',
  confirmed_at: Time.current
)

puts "✅ Created sample customer: #{customer.email}"

# Create Sample Review
review = Review.create!(
  business: business,
  user: customer,
  rating: 5,
  review_title: 'Excellent Service!',
  review_text: 'John and his team did an amazing job fixing our kitchen cabinets and installing new shelving. Professional, punctual, and reasonably priced. Highly recommend!',
  verified_purchase: true,
  active: true
)

puts "✅ Created sample review for #{business.business_name}"

# Create Sample Inquiry
inquiry = Inquiry.create!(
  business: business,
  user: customer,
  subject: 'Bathroom Renovation Quote',
  message: 'Hi, I would like to get a quote for a bathroom renovation. The bathroom is approximately 6x8 feet and needs new flooring, vanity, and paint. When would be a good time to schedule an estimate?',
  contact_phone: '15550456789',  # Fixed phone format
  preferred_contact_method: 'phone',
  status: 'pending'
)

puts "✅ Created sample inquiry for #{business.business_name}"

puts "🎉 Seeding completed successfully!"
puts ""
puts "📧 Login Credentials:"
puts "Admin: admin@jodislist.com / Admin123!"
puts "Business Owner: business@example.com / Business123!"
puts "Customer: customer@example.com / Customer123!"