class AdminUser < ApplicationRecord
  include AdminUserPermissions
  devise :database_authenticatable, :recoverable,
         :rememberable, :validatable, :trackable

  def full_name
    [*first_name, *last_name].join(' ')
  end

  validates :first_name, presence: true
  validates :last_name, presence: true
end
