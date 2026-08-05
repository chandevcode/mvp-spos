class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  acts_as_tenant(:tenant)

  enum :role, { admin: 0, owner: 1 }, default: :admin

  belongs_to :tenant
  has_many :transactions, dependent: :destroy
end
