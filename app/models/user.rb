class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  acts_as_tenant(:tenant)

  enum :role, { admin: 0, owner: 1 }, default: :owner

  belongs_to :tenant
  has_many :transactions, dependent: :destroy

  attr_accessor :skip_password_validation

  validates :role, presence: true
  validates :name, presence: true, length: { maximum: 100 }
  validates :address, length: { maximum: 255 }, allow_blank: true
  validates :phone_number, length: { maximum: 20 }, allow_blank: true,
            format: { with: /\A\+?[\d\s\-()]*\z/, message: "only allows numbers, spaces, dashes, and parentheses" }
  validate :tenant_admin_limit, on: :create, if: :admin?

  def password_required?
    return false if skip_password_validation
    super
  end

  private

  def tenant_admin_limit
    return unless tenant

    admin_count = tenant.users.admin.count
    if admin_count >= 2
      errors.add(:role, "limit reached. Each tenant can have a maximum of 2 staff/admin users.")
    end
  end
end
