class Tenant < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :transaction_items, dependent: :destroy
  has_many :subscription_payments, dependent: :destroy

  enum :subscription_status, { inactive: 0, active: 1, expired: 2, canceled: 3 }, default: :inactive

  validates :name, presence: true

  scope :subscribed, -> { where(subscription_status: :active) }

  def subscribed?
    active? && subscription_expires_at.present? && subscription_expires_at > Time.current
  end

  def subscription_plan_label
    case subscription_plan
    when "monthly" then "Monthly"
    when "annual" then "Annual"
    else "-"
    end
  end

  def activate_subscription!(plan_type)
    update!(
      subscription_status: :active,
      subscription_plan: plan_type,
      subscribed_at: Time.current,
      subscription_expires_at: plan_type == "monthly" ? 1.month.from_now : 12.months.from_now
    )
  end

  def days_until_expiry
    return 0 unless subscription_expires_at
    (subscription_expires_at.to_date - Date.current).to_i
  end
end
