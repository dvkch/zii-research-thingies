# frozen_string_literal: true

class AuthorizationAdapter < ActiveAdmin::AuthorizationAdapter
  def authorized?(action, subject = nil)
    case subject
    when normalized(ActiveAdmin::Page)
      return true if subject&.name == 'Dashboard'
      return true if subject&.name == 'Docs'
      return true if subject&.name == 'Stats' && user.permission?(:admin)
      return true if subject&.name == 'Health' && user.permission?(:admin)
      return true if subject&.name == 'Sidekiq' && user.permission?(:admin)
      user.permission?(:admin)

    when normalized(AdminUser)
      return true if [:read, :update].include?(action) && subject == user
      user.permission?(:admin)

    else
      user.permission?(:admin)
    end
  end
end
