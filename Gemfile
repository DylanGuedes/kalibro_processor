source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.4'

# Use PostgreSQL as the database for Active Record
gem 'pg'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use Rails Html Sanitizer for HTML sanitization
gem 'rails-html-sanitizer', '~> 1.0'

# Kalibro integration
gem 'kalibro_client', '~> 1.4'

# YAML parser required for properly compactibility between mri and rbx
gem 'psych', '~>2.0.12'

# Repository cloning
gem 'git', '~> 1.2.7'

# Clean the database for acceptance test
# Version should be greater than 1.4.1. See:
# https://github.com/DatabaseCleaner/database_cleaner/issues/317
gem 'database_cleaner', '>= 1.4.1', require: false

# Create a processing queue
gem 'delayed_job_active_record', '~> 4.0.1'

# Required for workers creation
gem 'daemons', '~> 1.2.2'

# Sends a email whenever there is a unexpected exception
gem 'exception_notification', '~> 4.1.0'

#
# Enables to export the delayed_job queue to system's task manager
#
# For usage instructions see the commit message at:
# https://github.com/ddollar/foreman/commit/67ffbe2aa29cdb04335e5f7d30fe874c1ddf26e0
#
# foreman export systemd /usr/lib/systemd/system -a kalibro_processor -c worker=10
#
gem 'foreman', '~> 0.78.0'

group :test do
  # Easier test writing
  gem "shoulda-matchers", '~>2.8.0'

  # Test coverage
  gem 'simplecov', require: false

  # Test Coverage monitoring
  gem "codeclimate-test-reporter", require: nil

  # Simple Mocks
  gem 'mocha', :require => 'mocha/api'
end

group :development, :test do
  # Call 'debugger' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', group: :development

  # Test framework
  gem 'rspec-rails', '~> 3.3.2'

  # Fixtures made easy
  gem 'factory_girl_rails', '~> 4.5.0'

  # Deployment
  gem 'capistrano', "~>3.4.0", require: false
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm', "~>0.1.0"
end

# Acceptance tests
group :cucumber do
  gem 'cucumber', '~> 1.3.10'
  gem 'cucumber-rails'
  # gem 'database_cleaner' # Removed because it is getting added above.
end

# Some statistics
gem 'descriptive-statistics', '~> 2.1.2'

# Ruby Collector
gem 'metric_fu', '~> 4.12.0'
gem 'debug_inspector' # this is a dependency after updating metric_fu to 4.11.4

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
