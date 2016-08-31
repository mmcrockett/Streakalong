require 'test_helper'

class ItemsControllerTest < ActionController::TestCase
  test "json index should get item data" do
    request_json
    get :index

    expected = []

    Item::ALL.each do |name|
      expected << {:name => name, :id => Item.id(name), :kcal => Item.kcal(name)}
    end

    assert_response :success
    assert_equal(JSON.parse(expected.to_json), JSON.parse(@response.body))
  end
end
