level = Rails.env.production? ? Logger::INFO : Logger::DEBUG

Rails.logger.level = level
ActiveRecord::Base.logger.level = level
