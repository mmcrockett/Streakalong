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

  def logged_in(user_id = users(:bbobberson).id)
    @request.session[:user_id] = user_id
  end

  def credentials(username = 'bbobberson')
    return {:username => username, :password => 'somepassword'}
  end
end
