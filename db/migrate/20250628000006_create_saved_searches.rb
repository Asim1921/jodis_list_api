# db/migrate/20250628000006_create_saved_searches.rb
class CreateSavedSearches < ActiveRecord::Migration[8.0]
  def change
    create_table :saved_searches do |t|
      t.references :user, null: false, foreign_key: true
      t.string :search_name
      t.json :search_params
      t.boolean :email_notifications, default: false
      t.integer :notification_frequency, default: 0 # daily, weekly, monthly
      t.datetime :last_notification_sent
      t.boolean :active, default: true
      
      t.timestamps
    end
    
    add_index :saved_searches, [:user_id, :active]
    add_index :saved_searches, :email_notifications
  end
end