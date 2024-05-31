require 'simplecov'
require 'spec_helper'
require 'shoulda/matchers'

SimpleCov.start
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

# Dotenv.load('.env.test')
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  # config.use_transactional_fixtures = false
  config.include FactoryBot::Syntax::Methods
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!  

  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end
end
