ActiveAdmin.register_page 'Dashboard' do
  menu priority: 0, label: proc { I18n.t('admin.pages.home') }

  content do
    para "Welcome #{current_admin_user.full_name}!"
  end
end
