# db/migrate/20250628000007_enhance_reviews.rb
class EnhanceReviews < ActiveRecord::Migration[8.0]
  def change
    # Add more review tracking fields
    add_column :reviews, :helpful_count, :integer, default: 0
    add_column :reviews, :verified_reviewer, :boolean, default: false
    add_column :reviews, :response_from_owner, :text
    add_column :reviews, :owner_response_date, :datetime
    add_column :reviews, :photos_attached, :boolean, default: false
    add_column :reviews, :service_date, :date
    add_column :reviews, :project_cost_range, :string
    add_column :reviews, :would_recommend, :boolean
    add_column :reviews, :response_time_rating, :integer # 1-5 scale
    add_column :reviews, :quality_rating, :integer # 1-5 scale
    add_column :reviews, :value_rating, :integer # 1-5 scale
    
    # External platform tracking
    add_column :reviews, :external_platform, :string
    add_column :reviews, :external_review_id, :string
    add_column :reviews, :external_url, :string
    add_column :reviews, :last_synced_at, :datetime
    
    # Add indexes
    add_index :reviews, :helpful_count
    add_index :reviews, :verified_reviewer
    add_index :reviews, :service_date
    add_index :reviews, :would_recommend
    add_index :reviews, [:external_platform, :external_review_id], unique: true
    add_index :reviews, :last_synced_at
  end
end