# app/models/inquiry.rb
class Inquiry < ApplicationRecord
  belongs_to :business
  belongs_to :user

# Fixed enum syntax for Rails 8
  enum :status, {
    pending: 0,
    in_progress: 1,
    responded: 2,
    closed: 3
  }

  validates :message, presence: true, length: { maximum: 2000 }
  validates :subject, length: { maximum: 100 }
  validates :contact_phone, format: { with: /\A[\+]?[1-9][\d]{0,15}\z/ }, allow_blank: true

  scope :recent, -> { order(created_at: :desc) }
  scope :unanswered, -> { where(status: [:pending, :in_progress]) }

  def response_time
    return nil unless responded_at
    
    ((responded_at - created_at) / 1.hour).round(1)
  end

  def mark_responded!(response_text)
    update!(
      status: :responded,
      business_response: response_text,
      responded_at: Time.current
    )
  end
end