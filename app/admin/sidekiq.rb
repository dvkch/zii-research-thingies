# frozen_string_literal: true

require 'sidekiq/api'

ActiveAdmin.register_page 'Sidekiq' do
  menu parent: 'advanced', priority: 4, label: proc { I18n.t('admin.pages.sidekiq') }

  content do
    if Rails.application.config.active_job.queue_adapter == :sidekiq
      iframe(
        src: sidekiq_web_path,
        class: 'admin_email_preview_iframe'
      )
    else
      para I18n.t('admin.labels.no_sidekiq')
    end
  end
end
