class ApplicationController < ActionController::Base
  protect_from_forgery

  before_action :set_locale

  private

  def extract_locale
    valid = Rails.application.config.i18n.available_locales
    accept = request.env['HTTP_ACCEPT_LANGUAGE'] || ''
    accept
      .scan(/[a-z]{2}/)
      .select { |lang| valid.include? lang.to_sym }
      .first
  end

  def set_locale
    # we could add `current_user&.try(:user_segment)&.locale`, but it seems preferable to use the browser's header
    # instead, a user might be associated to a segment because of their country of residence but not speak the
    # main language of the country
    I18n.locale = extract_locale || I18n.default_locale
  end

  # admin controller: show why a resource couldn't be deleted
  def flash_interpolation_options
    options = {}

    options[:resource_errors] =
      if resource&.errors&.any?
        "#{resource.errors.full_messages.to_sentence}."
      else
        ''
      end

    options
  end
end
