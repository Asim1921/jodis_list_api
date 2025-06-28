# db/migrate/xxx_create_business_category_assignments.rb
class CreateBusinessCategoryAssignments < ActiveRecord::Migration[7.0]
  def change
    create_table :business_category_assignments do |t|
      t.references :business, null: false, foreign_key: true
      t.references :business_category, null: false, foreign_key: true

      t.timestamps
    end

    add_index :business_category_assignments, [:business_id, :business_category_id], 
              unique: true, name: 'index_business_categories_on_business_and_category'
  end
end