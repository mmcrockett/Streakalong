require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should get welcome" do
    get :welcome
    assert_response :success
  end

  test "should create user" do
    request_json

    assert_nil(session[:user_id])

    assert_difference('User.count') do
      post :create, { password: 'somepassword', name: 'somename', username: 'someuser'}
    end

    assert_response :success
    assert_equal({}, JSON.parse(@response.body))
  end

  test "should get settings" do
    request_json
    logged_in

    get :settings

    assert_response :success
    assert_equal({"name"=>"Bob Bobberson", "height"=>nil, "birthday"=>nil, "gender"=>nil}, JSON.parse(@response.body))
  end

  test "update should set settings" do
    request_json
    logged_in

    post :update, {"name"=>"Bob Bobberson", "height"=>180, "birthday"=>nil, "gender"=>"male"}

    assert_response :success
    assert_equal({"name"=>"Bob Bobberson", "height"=>180, "birthday"=>nil, "gender"=>"male"}, JSON.parse(@response.body))
  end

  test "should be logged in to see settings" do
    get :settings
    assert_redirected_to(:action => "welcome")

    request_json
    get :settings
    assert_response :unauthorized
    post :settings
    assert_response :unauthorized
  end

  test "failure on create should report json error." do
    request_json

    assert_nil(session[:user_id])

    assert_no_difference('User.count') do
      post :create, { password: 'abc', name: 'somename', username: 'someuser'}
    end

    assert_nil(assigns['user'])
    assert_response :unprocessable_entity
    assert_equal({"password" => ["is too short (minimum is 6 characters)"]}, JSON.parse(@response.body))
  end

  test "should login user" do
    request_json

    post :login, { password: 'somepassword', username: 'bbobberson'}

    assert_response :success
    assert_equal(1, session[:user_id])
    assert_equal({}, JSON.parse(@response.body))
  end

  test "should fail login user" do
    request_json

    post :login, { password: 'badpassword', username: 'bbobberson'}

    assert_response :unauthorized
    assert_equal({}, JSON.parse(@response.body))
    assert_nil(assigns['user'])
    assert_nil(session[:user_id])
  end

  test "should logout user" do
    get :logout

    assert_nil(session[:user_id])
    assert_nil(assigns['user'])
    assert_redirected_to(:action => "welcome")
  end

  test "should redirect to activities if already logged in" do
    logged_in(2)

    post :login, { password: 'somepassword', username: ''}

    assert_equal(2, assigns['user'].id)
    assert_redirected_to('/activities')
  end

  test "should redirect to acitivities if already logged in and settings are incomplete and ignore_incomplete_settings is true" do
    logged_in(3)

    post :login, { password: 'somepassword', username: 'bbobberson'}

    assert_equal(3, assigns['user'].id)
    assert_redirected_to('/activities')
  end

  test "should redirect to settings if already logged in and settings are incomplete" do
    logged_in

    post :login, { password: 'somepassword', username: 'bbobberson'}

    assert_equal(1, assigns['user'].id)
    assert_redirected_to('/settings')
  end

  test "should redirect to specific url if supplied and if already logged in" do
    logged_in
    @request.session[:return_url] = ('/streaks')

    post :login, { password: 'somepassword', username: 'bbobberson'}

    assert_equal(1, assigns['user'].id)
    assert_redirected_to('/streaks')
  end

  test "should logout when user is invalid" do
    @request.session[:user_id] = -1

    get :logout

    assert_equal(0, session.keys.size)
    assert_nil(assigns['user'])
    assert_redirected_to('/welcome')
  end
end
