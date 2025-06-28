# app/models/business_category_assignment.rb
class BusinessCategoryAssignment < ApplicationRecord
  belongs_to :business
  belongs_to :business_category

  validates :business_id, uniqueness: { scope: :business_category_id }
end