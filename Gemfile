source 'https://rubygems.org'

ruby '2.6.1'

gem 'hanami',       '~> 1.3'
gem 'hanami-model', '~> 1.3'
gem 'rake'
gem 'rubocop', '~> 0.68.0'
gem 'rubocop-performance'

gem 'pg'

group :development do
  # Code reloading
  # See: http://hanamirb.org/guides/projects/code-reloading
  gem 'shotgun', platforms: :ruby
  gem 'hanami-webconsole'
end

group :test, :development do
  gem 'dotenv', '~> 2.4'
  gem 'pry', '~> 0.12.2'
end

group :test do
  gem 'rspec'
  gem 'capybara'
end

group :production do
  # gem 'puma'
end
