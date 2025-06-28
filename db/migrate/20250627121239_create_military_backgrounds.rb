class CreateMilitaryBackgrounds < ActiveRecord::Migration[8.0]
  def change
    create_table :military_backgrounds do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.integer :military_relationship, null: false
      t.string :branch_of_service
      t.string :rank
      t.string :mos_specialty
      t.date :service_start_date
      t.date :service_end_date
      t.text :additional_info
      t.boolean :verified, default: false

      t.timestamps
    end

    # Remove this line since t.references already creates the unique index:
    # add_index :military_backgrounds, :user_id, unique: true
    
    # Only add indexes that aren't automatically created:
    add_index :military_backgrounds, :military_relationship
    add_index :military_backgrounds, :verified
  end
end