# db/migrate/20250628000008_create_business_analytics.rb
class CreateBusinessAnalytics < ActiveRecord::Migration[8.0]
  def change
    create_table :business_analytics do |t|
      t.references :business, null: false, foreign_key: true
      t.date :date
      t.integer :page_views, default: 0
      t.integer :profile_views, default: 0
      t.integer :phone_clicks, default: 0
      t.integer :email_clicks, default: 0
      t.integer :website_clicks, default: 0
      t.integer :direction_requests, default: 0
      t.integer :inquiry_submissions, default: 0
      t.integer :review_submissions, default: 0
      t.json :traffic_sources # {'direct' => 50, 'google' => 30, 'referral' => 20}
      t.json :search_keywords # keywords that led to views
      
      t.timestamps
    end
    
    add_index :business_analytics, [:business_id, :date], unique: true
    add_index :business_analytics, :date
    add_index :business_analytics, :page_views
  end
end