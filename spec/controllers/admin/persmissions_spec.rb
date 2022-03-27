require 'rails_helper'

feature 'admin is scoped using AdminUser permissions' do
  before(:each) do
    I18n.locale = :fr
    Capybara.current_session.driver.header('Accept-Language', I18n.locale.to_s)
  end

  def permission_allows_menus(*menus)
    visit admin_dashboard_path

    tabs = all('#tabs .menu_item:not(.has_nested)').map(&:text)
    expect(tabs).to eq menus
  end

  def permission_logged_in_admin_user(can_delete: false, can_edit_permissions: false)
    visit admin_admin_user_path(@admin_user)

    expect(page).to have_link('Modifier ' + I18n.t('activerecord.models.admin_user.one'))

    if can_delete
      expect(page).to have_link('Supprimer ' + I18n.t('activerecord.models.admin_user.one'))
    else
      expect(page).not_to have_link('Supprimer ' + I18n.t('activerecord.models.admin_user.one'))
    end

    click_link 'Modifier ' + I18n.t('activerecord.models.admin_user.one')
    expect(current_path).to eq edit_admin_admin_user_path(@admin_user)

    if can_edit_permissions
      expect(page).to have_css('input[name="admin_user[permissions][]"][value="admin"]')
    else
      expect(page).not_to have_css('input[name="admin_user[permissions][]"][value="admin"]')
    end
  end

  def permission_model(object, permissions = [])
    model_name = I18n.t("activerecord.models.#{object.class.name.underscore}.one")

    index_path = Rails.application.routes.url_helpers.url_for([:admin, object.class, { only_path: true }])
    visit index_path

    if permissions.include?(:create)
      expect(current_path).to eq index_path
      expect(page).to have_link('Créer ' + model_name)
    else
      expect(page).not_to have_link('Créer ' + model_name)
    end

    view_path = Rails.application.routes.url_helpers.url_for([:admin, object, { only_path: true }])
    visit view_path

    if permissions.include?(:view)
      expect(current_path).to eq view_path
    else
      expect(current_path).to eq admin_dashboard_path
    end

    if permissions.include?(:edit)
      expect(page).to have_link('Modifier ' + model_name)
    else
      expect(page).not_to have_link('Modifier ' + model_name)
    end

    if permissions.include?(:delete)
      expect(page).to have_link('Supprimer ' + model_name)
    else
      expect(page).not_to have_link('Supprimer ' + model_name)
    end
  end

  context 'admin user' do
    before(:each) do
      @admin_user = create_and_log_admin(permissions: [:admin])
    end

    scenario 'can see all pages' do
      expected = [
        I18n.t('admin.pages.home'),

        I18n.t('activerecord.models.twitter_search.other'),

        I18n.t('activerecord.models.admin_user.other'),
      ]
      permission_allows_menus(*expected)
    end

    scenario 'can view, edit and delete its own admin user, including its permissions' do
      permission_logged_in_admin_user(can_delete: true, can_edit_permissions: true)
    end
  end

  scenario 'permissions: none' do
    @admin_user = create_and_log_admin(permissions: [])
    permission_logged_in_admin_user
    permission_allows_menus(
      I18n.t('admin.pages.home'),
    )
  end
end
