# db/migrate/xxx_create_business_categories.rb
class CreateBusinessCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :business_categories do |t|
      t.string :name, null: false
      t.text :description
      t.string :icon_class
      t.boolean :active, default: true
      t.integer :sort_order, default: 0

      t.timestamps
    end

    add_index :business_categories, :name, unique: true
    add_index :business_categories, :active
  end
end