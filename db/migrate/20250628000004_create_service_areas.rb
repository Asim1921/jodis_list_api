# db/migrate/20250628000004_create_service_areas.rb
class CreateServiceAreas < ActiveRecord::Migration[8.0]
  def change
    create_table :service_areas do |t|
      t.references :business, null: false, foreign_key: true
      t.string :area_type # 'city', 'county', 'state', 'zip_code', 'radius'
      t.string :area_name
      t.string :state_code
      t.string :country_code, default: 'US'
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.integer :radius_miles # for radius-based service areas
      t.boolean :primary_area, default: false
      
      t.timestamps
    end
    
    add_index :service_areas, [:business_id, :area_type]
    add_index :service_areas, [:area_name, :state_code]
    add_index :service_areas, [:latitude, :longitude]
    add_index :service_areas, :primary_area
  end
end
