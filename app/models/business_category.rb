# app/models/business_category.rb
class BusinessCategory < ApplicationRecord
  has_many :business_category_assignments, dependent: :destroy
  has_many :businesses, through: :business_category_assignments

  validates :name, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :sort_order, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:sort_order, :name) }

  def businesses_count
    businesses.joins(:user).where(business_status: :approved).count
  end
end