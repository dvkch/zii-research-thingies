# frozen_string_literal: true

url = ENV['REDIS_URL']

unless url.blank?
  # config: http://manuelvanrijn.nl/sidekiq-heroku-redis-calc/

  Sidekiq.configure_client do |config|
    config.redis = { url: url, size: 1 }
  end

  Sidekiq.configure_server do |config|
    config.redis = { url: url, size: 10 }
  end
end
