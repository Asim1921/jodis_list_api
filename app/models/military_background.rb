# app/models/military_background.rb
class MilitaryBackground < ApplicationRecord
  belongs_to :user

 # Fixed enum syntax for Rails 8
  enum :military_relationship, {
    supporter: 0,
    active_duty: 1,
    national_guard: 2,
    reserves: 3,
    veteran: 4
  }

  validates :military_relationship, presence: true
  validates :branch_of_service, presence: true, if: -> { military_service_member? }
  validates :service_start_date, presence: true, if: -> { military_service_member? }
  validate :end_date_after_start_date

  scope :verified, -> { where(verified: true) }
  scope :service_members, -> { where.not(military_relationship: :supporter) }

  def military_service_member?
    !supporter?
  end

  def currently_serving?
    active_duty? || national_guard? || reserves?
  end

  def service_duration
    return nil unless service_start_date
    
    end_date = service_end_date || Date.current
    ((end_date - service_start_date) / 365.25).round(1)
  end

  private

  def end_date_after_start_date
    return unless service_start_date && service_end_date
    
    if service_end_date < service_start_date
      errors.add(:service_end_date, "must be after service start date")
    end
  end
end