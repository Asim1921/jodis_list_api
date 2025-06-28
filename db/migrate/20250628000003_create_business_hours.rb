# db/migrate/20250628000003_create_business_hours.rb
class CreateBusinessHours < ActiveRecord::Migration[8.0]
  def change
    create_table :business_hours do |t|
      t.references :business, null: false, foreign_key: true
      t.integer :day_of_week # 0 = Sunday, 1 = Monday, etc.
      t.time :open_time
      t.time :close_time
      t.boolean :closed, default: false
      t.boolean :open_24_hours, default: false
      t.text :special_notes
      
      t.timestamps
    end
    
    add_index :business_hours, [:business_id, :day_of_week], unique: true
    add_index :business_hours, :day_of_week
  end
end