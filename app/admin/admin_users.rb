# frozen_string_literal: true

ActiveAdmin.register AdminUser do
  menu parent: 'advanced', priority: 1

  permit_params :email, :first_name, :last_name, :password, :password_confirmation, permissions: []

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  index do
    selectable_column
    id_column
    column :full_name
    AdminUser.all_permissions.each do |permission|
      column permission do |resource|
        resource.permission?(permission)
      end
    end
    actions
  end

  show do
    attributes_table do
      row :first_name
      row :last_name
      row :email
      row :sign_in_count
      row :current_sign_in_at
    end

    panel I18n.t('attributes.permissions') do
      permissions = AdminUser.all_permissions.map do |permission|
        { name: permission, description: AdminUser.permission_description(permission), value: resource.permission?(permission) }
      end
      index_table_for(permissions, class: 'index_table') do
        column :name
        column :description
        column :value
      end
    end

    attributes_table title: I18n.t('admin.labels.metadata') do
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :password
      f.input :password_confirmation

      if current_admin_user.permission?(:admin)
        f.input :permissions, as: :check_boxes,
                collection: AdminUser.all_permissions.map { |p| [AdminUser.permission_description(p), p.to_s] }
      end
    end

    f.actions
  end

  controller do
    def update
      if params[:admin_user][:password].blank?
        %w(password password_confirmation).each { |p| params[:admin_user].delete(p) }
      end
      super
    end
  end
end
