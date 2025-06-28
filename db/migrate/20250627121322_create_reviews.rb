class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.references :business, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text :review_text
      t.string :review_title
      t.boolean :verified_purchase, default: false
      t.boolean :active, default: true
      t.string :external_source
      t.string :external_id

      t.timestamps
    end

    # Add only the additional indexes we need:
    add_index :reviews, :rating
    add_index :reviews, :active
    add_index :reviews, [:business_id, :user_id], unique: true, name: 'index_reviews_on_business_and_user'
  end
end