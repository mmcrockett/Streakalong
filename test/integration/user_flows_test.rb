require 'test_helper'

class UserFlowsTest < ActionDispatch::IntegrationTest
  test "can see the welcome page from base url when not logged in" do
    get "/"
    assert_response :redirect
    follow_redirect!
    assert_select "title", /Login/
  end

  test "redirect remember works" do
    return
  end

  test "welcome page when logged in goes to activities" do
    get "/users.json", credentials('mikemikerson')
    assert_response :accepted
    get "/welcome"
    assert_response :redirect
    follow_redirect!
    assert_select "title", /Activities/
  end

  test "is redirected to settings if incomplete after login" do
    get "/"
    assert_response :redirect
    follow_redirect!
    assert_select "title", /Login/
    get "/users.json", credentials()
    assert_response :accepted
    get "/"
    assert_response :redirect
    follow_redirect!
    assert_response :redirect
    follow_redirect!
    assert_select "title", /Settings/
  end

  test "is redirected to activities if incomplete and ignoreincomplete after login" do
    get "/"
    assert_response :redirect
    follow_redirect!
    assert_select "title", /Login/
    get "/users.json", credentials('rrobberson')
    assert_response :accepted
    get "/"
    assert_response :redirect
    follow_redirect!
    assert_response :redirect
    follow_redirect!
    assert_select "title", /Activities/
  end

  test "is redirected to activities if complete after login" do
    get "/"
    assert_response :redirect
    follow_redirect!
    assert_select "title", /Login/
    get "/users.json", credentials('mikemikerson')
    assert_response :accepted
    get "/"
    assert_response :redirect
    follow_redirect!
    assert_response :redirect
    follow_redirect!
    assert_select "title", /Activities/
  end
end
