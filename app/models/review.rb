# app/models/review.rb
class Review < ApplicationRecord
  belongs_to :business
  belongs_to :user

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :review_text, length: { maximum: 1000 }
  validates :review_title, length: { maximum: 100 }
  validates :user_id, uniqueness: { scope: :business_id, message: "can only review a business once" }

  scope :active, -> { where(active: true) }
  scope :verified, -> { where(verified_purchase: true) }
  scope :by_rating, ->(rating) { where(rating: rating) }
  scope :recent, -> { order(created_at: :desc) }

  def verified?
    verified_purchase?
  end

  def external_review?
    external_source.present?
  end
end