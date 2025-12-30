source "https://rubygems.org"

ruby "3.3.8"

gem "rails", "~> 8.1.1"
gem "propshaft"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "jbuilder"
gem "bcrypt", "~> 3.1.7"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false
gem "motor-admin"
gem "appsignal"
gem "rack-attack"

# Stripe for payment processing
gem "stripe", "~> 12.0"

# Markdown processing
gem "kramdown", "~> 2.4"
gem "kramdown-parser-gfm", "~> 1.1"

# Environment variables
gem "dotenv-rails", groups: [ :development, :test ]

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false

  # RSpec for testing
  gem "rspec-rails", "~> 8.0"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.5"
end

group :development do
  gem "web-console"
  # Security vulnerability scanner
  gem "bundler-audit", require: false
  # Preview emails in browser
  gem "letter_opener"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "shoulda-matchers", "~> 6.0"
  gem "webmock", "~> 3.23"
end
