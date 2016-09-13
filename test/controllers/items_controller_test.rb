require 'test_helper'

class ItemsControllerTest < ActionController::TestCase
  test "json index should get item data" do
    image_key = "image_src"
    request_json
    get :index

    expected = []

    Item::ALL.each do |name|
      expected << {:name => name, :id => Item.id(name), :kcal => Item.kcal(name)}
    end

    assert_response :success
    items_returned = JSON.parse(@response.body)

    items_returned.each do |item|
      assert(item[image_key].include?("items"))
      assert(item[image_key].include?("#{item[:name]}.png"))
      item.delete(image_key)
    end

    assert_equal(JSON.parse(expected.to_json), items_returned)
  end
end
