# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable

  # Fixed enum syntax for Rails 8
  enum :role, { 
    customer: 0, 
    business_owner: 1, 
    admin: 2, 
    employee: 3 
  }
  
  enum :membership_status, { 
    supporter: 0,
    member: 1, 
    spouse: 2,
    veteran: 3 
  }

  # Associations
  has_one :business, dependent: :destroy
  has_one :military_background, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :inquiries, dependent: :destroy
  has_one_attached :avatar
  has_many_attached :documents

  # Validations
  validates :first_name, :last_name, presence: true
  validates :phone, format: { with: /\A[\+]?[1-9][\d]{0,15}\z/ }, allow_blank: true
  validates :role, presence: true
  validates :membership_status, presence: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :veterans, -> { where(membership_status: :veteran) }
  scope :business_owners, -> { where(role: :business_owner) }

  # Methods
  def full_name
    "#{first_name} #{last_name}".strip
  end

  def military_verified?
    military_background&.verified?
  end

  def has_business?
    business.present?
  end

  def membership_priority
    case membership_status
    when 'veteran' then 1
    when 'spouse' then 2
    when 'member' then 3
    when 'supporter' then 4
    else 5
    end
  end

  def active_for_authentication?
    super && active?
  end

  def inactive_message
    active? ? super : :account_inactive
  end
end