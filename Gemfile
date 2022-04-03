source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.3'

gem 'rails', '~> 6.1.5'

gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'rack-cors', '~> 1.1'
gem 'rspec-rails', '~> 5.0'

gem 'font_awesome5_rails', '~> 1.5'
gem 'rails-i18n', '~> 6.0'
gem 'sass-rails', '~> 6.0'
gem 'turbolinks', '~> 5'

gem 'bcrypt', '~> 3.1'
gem 'devise', '~> 4.7'
gem 'modularity', '~> 3.0'
gem 'parallel', '~> 1.22.1'
gem 'pg_search', '~> 2.3'
gem 'rest-client', '~> 2.1'
gem 'sidekiq', '~> 6.3'

gem 'activeadmin', '~> 2.7'
gem 'activeadmin_addons', '~> 1.7'
gem 'arctic_admin', '~> 3.2'
gem 'chartkick', '~> 4.1'
gem 'groupdate', '~> 6.0'

gem 'tweetkit', '~> 0.2'

gem 'bootsnap', '>= 1.4.4', require: false

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'faker', '~> 2.13'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  gem 'capybara', '~> 3.34'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'selenium-webdriver', '~> 4.1'
  gem 'shoulda-matchers', '~> 5.1'
  gem 'simplecov', '~> 0.19', require: false
  gem 'sinatra', '~> 2.1'
  gem 'timecop', '~> 0.9'
  gem 'webmock', '~> 3.9'
end

group :tools do
  gem 'rubocop', '~> 1.26'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
