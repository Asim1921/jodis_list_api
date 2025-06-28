# db/migrate/20250628000001_add_module2_fields_to_businesses.rb
class AddModule2FieldsToBusinesses < ActiveRecord::Migration[8.0]
  def change
    # Add new business fields for enhanced functionality
    add_column :businesses, :years_in_business, :integer
    add_column :businesses, :employee_count, :integer
    add_column :businesses, :emergency_service, :boolean, default: false
    add_column :businesses, :insured, :boolean, default: false
    add_column :businesses, :bonded, :boolean, default: false
    add_column :businesses, :background_checked, :boolean, default: false
    add_column :businesses, :services_offered, :text
    add_column :businesses, :payment_methods, :string, array: true, default: []
    add_column :businesses, :languages_spoken, :string, array: true, default: []
    
    # Enhanced status tracking
    add_column :businesses, :approved_at, :datetime
    add_column :businesses, :rejected_at, :datetime
    add_column :businesses, :suspended_at, :datetime
    add_column :businesses, :featured_at, :datetime
    add_column :businesses, :rejection_reason, :text
    add_column :businesses, :suspension_reason, :text
    add_column :businesses, :admin_notes, :text
    
    # Business verification fields
    add_column :businesses, :verification_status, :integer, default: 0
    add_column :businesses, :verification_documents_required, :boolean, default: false
    add_column :businesses, :verification_notes, :text
    add_column :businesses, :last_verification_date, :datetime
    
    # SEO and marketing fields
    add_column :businesses, :keywords, :string, array: true, default: []
    add_column :businesses, :social_media_links, :json
    add_column :businesses, :promotional_message, :text
    add_column :businesses, :special_offers, :json
    
    # Analytics tracking
    add_column :businesses, :view_count, :integer, default: 0
    add_column :businesses, :inquiry_count, :integer, default: 0
    add_column :businesses, :last_activity_at, :datetime
    
    # Add indexes for better performance
    add_index :businesses, :years_in_business
    add_index :businesses, :employee_count
    add_index :businesses, :emergency_service
    add_index :businesses, :insured
    add_index :businesses, :bonded
    add_index :businesses, :verification_status
    add_index :businesses, :approved_at
    add_index :businesses, :view_count
    add_index :businesses, :inquiry_count
    add_index :businesses, :last_activity_at
    
    # Composite indexes for common queries
    add_index :businesses, [:business_status, :featured, :verified]
    add_index :businesses, [:state, :city, :business_status]
    add_index :businesses, [:emergency_service, :insured, :business_status]
    
    # GIN indexes for array columns (PostgreSQL specific)
    add_index :businesses, :payment_methods, using: :gin
    add_index :businesses, :languages_spoken, using: :gin
    add_index :businesses, :keywords, using: :gin
  end
end