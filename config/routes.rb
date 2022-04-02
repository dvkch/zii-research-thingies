require 'sidekiq/web'

Rails.application.routes.draw do
  root to: 'home#index'

  # admin users
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # jobs
  authenticate :admin_user, ->(admin) { admin.permission?(:admin) } do
    mount Sidekiq::Web => '/admin/sidekiq/ui'
  end

  # test
  get 'test_route', to: 'home#test_route' if Rails.env.test?
end
