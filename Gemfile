source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '2.6.5'
gem 'rails', '~> 5.2.4.3'
# Use sqlite3 as the database for Active Record
gem 'haml-rails'
gem 'newrelic_rpm'
gem 'pg'
# Use jquery as the JavaScript library
gem 'jquery-rails', '4.1.1'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'cancan'
gem 'formtastic'
gem 'jbuilder', '~> 2.0'
gem 'rails_admin', '~> 1.3'
gem 'redis', '~> 4.0'
gem 'sidekiq'

gem 'autoprefixer-rails', '8.6.5'
gem 'aws-sdk-s3', require: false
gem 'best_in_place'
gem 'contact_us', '~> 0.5.1'
gem 'devise'
gem 'foundation-icons-sass-rails'
gem 'foundation-rails', '= 5.4.5'
gem 'meta-tags'
gem 'omniauth', '~> 1.3.2'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem 'paperclip'
gem 'rails_12factor'
gem 'sass-rails', '= 5.0.7'
gem 'simple_captcha2', require: 'simple_captcha'
gem 'sitemap_generator'
gem 'stripe', git: 'https://github.com/stripe/stripe-ruby'
gem 'tinymce-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'active_model_serializers', '~> 0.10.0'
gem 'coffee-rails', '~> 4.2'
gem 'dotenv-rails'
group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '~> 3.0.5'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
