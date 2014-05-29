require 'test_helper'

class UserItemsControllerTest < ActionController::TestCase
  setup do
    @user_item = user_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_item" do
    assert_difference('UserItem.count') do
      post :create, user_item: { amount: @user_item.amount, date: @user_item.date, item_id: @user_item.item_id, references: @user_item.references }
    end

    assert_redirected_to user_item_path(assigns(:user_item))
  end

  test "should show user_item" do
    get :show, id: @user_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user_item
    assert_response :success
  end

  test "should update user_item" do
    put :update, id: @user_item, user_item: { amount: @user_item.amount, date: @user_item.date, item_id: @user_item.item_id, references: @user_item.references }
    assert_redirected_to user_item_path(assigns(:user_item))
  end

  test "should destroy user_item" do
    assert_difference('UserItem.count', -1) do
      delete :destroy, id: @user_item
    end

    assert_redirected_to user_items_path
  end
end
