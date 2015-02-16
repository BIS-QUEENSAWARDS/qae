source 'https://rubygems.org'

gem 'rails', '4.1.8'

gem 'dotenv-rails', '~> 1.0'

gem 'coffee-rails', '~> 4.0.0'
gem 'devise', '~> 3.4'
gem 'enumerize', '~> 0.8'
gem 'govuk_frontend_toolkit', github: 'alphagov/govuk_frontend_toolkit_gem', submodules: true
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'kaminari', '~> 0.16'
gem 'pg', '~> 0.17'
gem 'plek', '~> 1.9.0'
gem 'responders', '~> 1.1'
gem 'sentry-raven', github: 'getsentry/raven-ruby'
gem 'simple_form', '~> 3.0'
gem 'slim-rails', '~> 2.1'
gem "govuk_template", "0.12.0"
gem 'wicked', '~> 1.1'
gem 'prawn'
gem 'prawn-table'
gem 'draper'
gem 'decent_exposure'
gem 'decent_decoration'
gem 'country_select'
gem "email_validator"
gem "nokogiri"

# Background jobs
gem 'sidekiq'
gem 'sidekiq-status'
gem 'sinatra', require: false
gem 'foreman'
gem 'jquery.fileupload-rails'
gem 'carrierwave'

group :assets do
  gem 'uglifier', '>= 1.3.0'
end

group :test do
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'rspec-rails'
  gem 'turnip'
  gem 'shoulda-matchers', require: false
  gem 'pdf-inspector', require: 'pdf/inspector'
  gem 'rspec-sidekiq'
  gem 'codeclimate-test-reporter', group: :test, require: nil
end

group :development do
  gem 'capistrano', '~> 3.2.0'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-rbenv'
  gem 'capistrano-sidekiq'
  gem 'slackistrano', require: false
  gem 'pry'
  gem 'letter_opener'
  gem 'quiet_assets'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rack-mini-profiler', require: false
end

group :test, :development do
  gem 'factory_girl_rails'
end