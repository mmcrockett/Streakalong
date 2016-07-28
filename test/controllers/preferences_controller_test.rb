require 'test_helper'

class PreferencesControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
  end

  test "should get preferences if we're logged in" do
    request_json
    logged_in

    get :index

    assert_response :success
    assert_equal(JSON.parse(assigns['user'].preferences.to_json), JSON.parse(@response.body))
  end

  test "should fail if we're not logged in" do
    request_json

    get :index

    assert_response :unauthorized
  end

  test "should not modify preference if we're not logged in" do
    request_json

    post :create, { :item_tab => 'foods' }

    assert_response :unauthorized
  end

  test "should modify preference" do
    request_json
    logged_in

    data = { :item_tab => 'foods', :recent => [1,2,3] }

    post :create, data

    assert_response :created

    preferences = JSON.parse(@response.body)
    assert_equal('foods', preferences[Preference::ITEM_TAB])
    assert_equal(3, preferences[Preference::RECENT].length)
    assert_equal(JSON.parse(assigns['user'].preferences.to_json), JSON.parse(@response.body))
  end

  test "should ignore invalid preference" do
    request_json
    logged_in

    post :create, { :fake_pref => 'newvalueyes1' }

    assert_response :created
    assert_not(@response.body.include?('newvalueyes1'))
    assert_equal(JSON.parse(assigns['user'].preferences.to_json), JSON.parse(@response.body))
  end
end
