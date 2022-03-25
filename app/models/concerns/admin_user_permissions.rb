# frozen_string_literal: true

module AdminUserPermissions
  extend ActiveSupport::Concern

  included do
    before_validation :cleanup_permissions
    validate :valid_permissions?

    # class methods
    def self.all_permissions
      [
        :admin
      ]
    end

    def self.permission_description(permission)
      I18n.t("activerecord.enums.admin_user.permissions.#{permission}", default: nil)
    end

    # access methods
    def permission?(permission)
      # if a user is :admin then all permissions are granted
      return true if permissions.map(&:to_sym).include?(:admin)

      permissions.map(&:to_sym).include?(permission.to_sym)
    end

    private

    def cleanup_permissions
      self.permissions = permissions.reject(&:blank?)
    end

    def valid_permissions?
      invalid = permissions.reject { |p| AdminUser.all_permissions.include?(p.to_sym) }
      errors.add(:permissions, I18n.t('errors.messages.invalid_permissions', permissions: invalid.join(', '))) unless invalid.empty?
    end
  end
end
