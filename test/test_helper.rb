ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def request_json
    @request.headers["Content-Type"] = 'application/json'
    @request.headers["Accept"]     = 'application/json'
  end

  def logged_in
    @request.session[:user_id] = 1
  end
end
