# db/migrate/20250628000002_enhance_business_categories.rb
class EnhanceBusinessCategories < ActiveRecord::Migration[8.0]
  def change
    # Add parent category support for hierarchical structure
    add_column :business_categories, :parent_id, :bigint
    add_column :business_categories, :level, :integer, default: 0
    add_column :business_categories, :requires_license, :boolean, default: false
    add_column :business_categories, :emergency_service, :boolean, default: false
    add_column :business_categories, :keywords, :string, array: true, default: []
    add_column :business_categories, :image_url, :string
    add_column :business_categories, :color_code, :string
    
    # SEO fields
    add_column :business_categories, :slug, :string
    add_column :business_categories, :meta_title, :string
    add_column :business_categories, :meta_description, :text
    
    # Add foreign key for parent category
    add_foreign_key :business_categories, :business_categories, column: :parent_id
    add_index :business_categories, :parent_id
    add_index :business_categories, :level
    add_index :business_categories, :requires_license
    add_index :business_categories, :emergency_service
    add_index :business_categories, :slug, unique: true
    add_index :business_categories, :keywords, using: :gin
  end
end