class CreateRealEstateAgents < ActiveRecord::Migration[8.0]
  def change
    create_table :real_estate_agents do |t|
      t.references :business, null: false, foreign_key: true, index: { unique: true }
      t.string :brokerage_name, null: false
      t.string :broker_email
      t.string :brokerage_phone
      t.string :brokerage_license_number
      t.text :specialties
      t.json :certifications

      t.timestamps
    end

    # Remove this line:
    # add_index :real_estate_agents, :business_id, unique: true
  end
end