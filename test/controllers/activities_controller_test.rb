require 'test_helper'

class ActivitiesControllerTest < ActionController::TestCase
  setup do
    @activities = []
    @activity   = activities(:one)
    
    [activities(:one), activities(:four)].each do |activity|
      @activities << {:id => activity.id, :amount => activity.amount, :date => activity.date, :item_id => activity.item_id}
    end

    @june_sixth_ms = (Date.new(2016, 6, 6).to_time.to_i * 1000)
  end

  test "json index should get activities for that date" do
    request_json
    logged_in

    get :index, {:date => @june_sixth_ms}

    assert_response :success
    assert_equal(JSON.parse(@activities.to_json), JSON.parse(@response.body))
  end

  test "index should get" do
    logged_in

    get :index

    assert_response :success
  end

  test "index should redirect when not logged in" do
    get :index

    assert_redirected_to('/welcome')
    assert(session[:return_url])
  end

  test "json index should fail when not logged in" do
    request_json

    get :index

    assert_response :unauthorized
    assert_nil(session[:return_url])
  end

  test "json post should create activity when no id present" do
    request_json
    logged_in

    assert_difference('Activity.count') do
      post :create, { amount: @activity.amount, date: @activity.date, item_id: @activity.item_id }
    end

    assert_response :success

    response_object = Activity.new(JSON.parse(@response.body))
    assert_equal(@activity.date, response_object.date)
    assert_equal(@activity.amount, response_object.amount)
    assert_equal(@activity.item_id, response_object.item_id)
    assert(response_object.id)
    assert_not_equal(@activity.id, response_object.id)
  end

  test "json post should not allow user id to be set and should set it to session user" do
    request_json
    logged_in

    post :create, { amount: @activity.amount, date: @activity.date, item_id: @activity.item_id, user_id: 8 }

    assert_response :success

    response_object = Activity.new(JSON.parse(@response.body))
    assert_equal(@activity.date, response_object.date)
    assert_equal(@activity.amount, response_object.amount)
    assert_equal(@activity.item_id, response_object.item_id)
    assert(response_object.id)
    assert_not_equal(@activity.id, response_object.id)
  end

  test "json post should fail when not logged in" do
    request_json

    post :create, { amount: @activity.amount, date: @activity.date, item_id: @activity.item_id }

    assert_response :unauthorized
    assert_nil(session[:return_url])
  end

  test "json post should only update activity amount when id is provided" do
    request_json
    logged_in

    post :create, { amount: @activity.amount + 1, date: 9, item_id: 9, id: @activity.id, :user_id => 9 }

    assert_response :success

    response_object = Activity.new(JSON.parse(@response.body))
    assert_equal(@activity.date, response_object.date)
    assert_equal(@activity.amount + 1, response_object.amount)
    assert_equal(@activity.item_id, response_object.item_id)
    assert(response_object.id)
    assert_equal(@activity.id, response_object.id)
  end

  test "json post should fail when id doesn't match item_id and date when id is provided" do
    request_json
    logged_in

    post :create, { amount: @activity.amount + 1, date: 9, item_id: 9, id: @activity.id, :user_id => 9 }

    assert_response :success

    response_object = Activity.new(JSON.parse(@response.body))
    assert_equal(@activity.date, response_object.date)
    assert_equal(@activity.amount + 1, response_object.amount)
    assert_equal(@activity.item_id, response_object.item_id)
    assert(response_object.id)
    assert_equal(@activity.id, response_object.id)
  end

  test "should logout when user is invalid" do
    @request.session[:user_id] = -1

    get :index

    assert_redirected_to('/logout')
  end

  test "should not redirect when user is invalid and request is json" do
    request_json
    @request.session[:user_id] = -1

    get :index

    assert_response :unauthorized
  end
end
