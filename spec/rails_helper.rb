require 'simplecov'
require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!
require 'shoulda/matchers'
SimpleCov.start
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# require 'database_cleaner'
# Dotenv.load('.env.test')
# Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
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
  
  # config.include Devise::TestHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :controller
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  config.include(Shoulda::Callback::Matchers::ActiveModel)
  # config.before(:suite) do
  #   DatabaseCleaner.clean_with(:truncation)
  # end
  # config.before(:each) do
  #   DatabaseCleaner.strategy = :transaction
  # end
  # config.before(:each, :js => true) do
  #   DatabaseCleaner.strategy = :truncation
  # end
  # config.before(:each) do
  #   DatabaseCleaner.start
  # end
  # config.after(:each) do
  #   DatabaseCleaner.clean
  # end
  # config.before(:all) do
  #   DatabaseCleaner.start
  # end
  # config.after(:all) do
  #   DatabaseCleaner.clean
  # end
  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end
end
