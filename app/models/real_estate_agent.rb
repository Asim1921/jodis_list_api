# app/models/real_estate_agent.rb
class RealEstateAgent < ApplicationRecord
  belongs_to :business

  validates :brokerage_name, presence: true, length: { maximum: 100 }
  validates :broker_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :brokerage_phone, format: { with: /\A[\+]?[1-9][\d]{0,15}\z/ }, allow_blank: true

  def has_certifications?
    certifications.present? && certifications.any?
  end
end