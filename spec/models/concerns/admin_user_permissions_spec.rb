require 'rails_helper'

RSpec.describe AdminUserPermissions, type: :model do
  it 'can save permissions' do
    admin = create(:admin_user)
    admin.permissions << :admin
    expect(admin.valid?).to eq true
    admin.save

    admin.reload
    expect(admin.permissions).to eq ['admin']
  end

  it 'validates that permissions exists' do
    admin = create(:admin_user)
    admin.permissions << :admin
    admin.permissions << :other_permission
    expect(admin.valid?).to eq false
    expect(admin.errors.messages_for(:permissions)).to eq [I18n.t('errors.messages.invalid_permissions', permissions: 'other_permission')]
  end

  it 'defines a permission_description class method' do
    AdminUser.all_permissions.each do |permission|
      expect(AdminUser.permission_description(permission)).not_to eq nil
      expect(AdminUser.permission_description(permission.to_s)).not_to eq nil
      # make sure it has been translated
      expect(AdminUser.permission_description(permission)).not_to include ".#{permission}"
    end
  end

  it 'defines a permission? method' do
    AdminUser.all_permissions.each do |permission|
      # no permission
      admin = create(:admin_user)
      expect(admin.permission?(permission.to_sym)).to eq false
      expect(admin.permission?(permission.to_s)).to eq false

      # with permission
      admin.permissions << permission
      expect(admin.permission?(permission.to_sym)).to eq true
      expect(admin.permission?(permission.to_s)).to eq true

      # with admin
      admin.permissions = [:admin]
      expect(admin.permission?(permission.to_sym)).to eq true
      expect(admin.permission?(permission.to_s)).to eq true
    end
  end
end
