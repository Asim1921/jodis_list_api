# db/migrate/xxx_create_businesses.rb
class CreateBusinesses < ActiveRecord::Migration[7.0]
  def change
    create_table :businesses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :business_name, null: false
      t.text :description
      t.string :business_phone
      t.string :business_email
      t.string :license_number
      t.text :areas_served
      t.string :website_url
      
      # Address fields
      t.string :address_line1
      t.string :address_line2
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :country, default: 'United States'
      
      # Geolocation
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      
      # Business status and features
      t.integer :business_status, default: 0
      t.boolean :featured, default: false
      t.boolean :verified, default: false
      
      # Business hours (JSON format)
      t.json :business_hours
      
      # SEO fields
      t.string :meta_title
      t.text :meta_description
      t.string :slug

      t.timestamps
    end

    add_index :businesses, :user_id, if_not_exists: true
    add_index :businesses, :business_status
    add_index :businesses, :featured
    add_index :businesses, :verified
    add_index :businesses, :slug, unique: true
    add_index :businesses, [:latitude, :longitude]
    
  end
end