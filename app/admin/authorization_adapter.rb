# frozen_string_literal: true

class AuthorizationAdapter < ActiveAdmin::AuthorizationAdapter
  def authorized?(action, subject = nil)
    case subject
    when normalized(ActiveAdmin::Page)
      return true if subject&.name == 'Dashboard'
      return true if subject&.name == 'Twitter Stats'
      return true if subject&.name == 'Twitter Trends'
      return true if subject&.name == 'Sidekiq' && user.permission?(:admin)
      user.permission?(:admin)

    when normalized(TwitterSearch)
      return true

    when normalized(TwitterTweet)
      return true

    when normalized(AdminUser)
      return true if [:read, :update].include?(action) && subject == user
      user.permission?(:admin)

    else
      user.permission?(:admin)
    end
  end
end
