source 'https://rubygems.org'

gem 'rails', '3.2.13'
gem 'therubyracer', :platforms => :ruby

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

group :staging, :production do
  gem 'mysql2'
  gem 'activerecord-mysql2-adapter'
end

group :development do
  gem 'capistrano',  '3.2.1'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-rvm'
  gem 'sqlite3'
end
