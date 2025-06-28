class CreateInquiries < ActiveRecord::Migration[8.0]
  def change
    create_table :inquiries do |t|
      t.references :business, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :subject
      t.text :message, null: false
      t.string :contact_phone
      t.string :preferred_contact_method
      t.datetime :preferred_contact_time
      t.integer :status, default: 0
      t.text :business_response
      t.datetime :responded_at

      t.timestamps
    end

    # Add only the additional index we need:
    add_index :inquiries, :status
  end
end