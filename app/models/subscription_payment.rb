class SubscriptionPayment < ApplicationRecord
  PLAN_TYPES = { "monthly" => 150_000, "annual" => 1_500_000 }.freeze
  PLAN_DURATIONS = { "monthly" => 1.month, "annual" => 12.months }.freeze

  has_secure_password :password, validations: false

  enum :status, { pending: 0, success: 1, failed: 2, expired: 3 }

  belongs_to :tenant, optional: true
  belongs_to :user, optional: true

  validates :email, presence: true, format: { with: Devise.email_regexp }
  validates :plan_type, inclusion: { in: PLAN_TYPES.keys }
  validates :amount, numericality: { greater_than: 0 }
  validates :midtrans_order_id, uniqueness: true, allow_nil: true

  before_validation :set_amount_and_order_id, on: :create

  def plan_duration
    PLAN_DURATIONS[plan_type]
  end

  def plan_label
    plan_type == "monthly" ? "Monthly" : "Annual"
  end

  def formatted_amount
    "Rp #{amount.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, '\\1.')}"
  end

  private

  def set_amount_and_order_id
    self.amount = PLAN_TYPES[plan_type]
    self.midtrans_order_id = "SPOS-#{plan_type.upcase}-#{Time.current.to_i}-#{SecureRandom.hex(4).upcase}"
  end
end
