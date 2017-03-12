# bundle install --path vendor/bundle --without=production



source 'https://rubygems.org'

gem 'rails', '4.2.3'
gem 'sqlite3'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'activerecord-import', '0.10.0'
gem 'kaminari', '0.16.3'
gem 'bootstrap-sass', '3.3.5.1'
gem 'whenever', '0.9.4', :require => false
gem 'elasticsearch-rails', '0.1.7'
gem 'elasticsearch-model', '0.1.7'
gem 'yaml_db', '0.3.0'
gem 'sanitize', '4.0.0'
gem 'sendgrid_ruby', '0.0.6'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :production do
	gem 'rails_12factor', '0.0.3'
	gem 'puma', '2.13.4'
	gem 'mysql2', '0.3.20'
end

