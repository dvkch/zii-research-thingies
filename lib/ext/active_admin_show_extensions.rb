# frozen_string_literal: true

class ActiveAdmin::Views::Pages::Show
  def deployable_panel(title, id = nil, opened: false)
    options = { class: 'panel' }
    options[:open] = 1 if opened || (id && params.fetch(:deployed, []).map(&:to_sym).include?(id))

    details options do
      summary { h3 title }
      yield
    end
  end
end

class ActiveAdmin::Views::ActiveAdminForm
  def deployable_panel(title, id = nil, opened: false)
    options = { class: 'panel' }
    options[:open] = 1 if opened || (id && params.fetch(:deployed, []).map(&:to_sym).include?(id))

    details options do
      summary { h3 title }
      yield
    end
  end
end
