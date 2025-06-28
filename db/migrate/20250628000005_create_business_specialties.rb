# db/migrate/20250628000005_create_business_specialties.rb
class CreateBusinessSpecialties < ActiveRecord::Migration[8.0]
  def change
    create_table :business_specialties do |t|
      t.references :business, null: false, foreign_key: true
      t.string :specialty_name, null: false
      t.text :description
      t.decimal :price_range_min, precision: 10, scale: 2
      t.decimal :price_range_max, precision: 10, scale: 2
      t.string :price_unit # 'per_hour', 'per_project', 'per_sqft', etc.
      t.boolean :featured, default: false
      t.integer :sort_order, default: 0
      
      t.timestamps
    end
    
    add_index :business_specialties, [:business_id, :featured]
    add_index :business_specialties, :sort_order
  end
end