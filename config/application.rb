require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ZiiResearchThingies
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.time_zone = 'UTC'

    config.generators.test_framework :rspec

    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths << Rails.root.join('lib/ext')

    config.i18n.available_locales = [:fr, :en]
    config.i18n.default_locale = :en
    config.i18n.fallbacks = [I18n.default_locale, { fr: :en, en: :fr }]
  end
end
