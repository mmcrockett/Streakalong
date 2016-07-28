require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  test "name should get the name by id" do
    Item::ALL.size.times do |i|
      assert(Item.name(i))
    end

    assert_raises do
      Item.name("1")
      Item.name(-1)
    end
  end

  test "id should get the id by name" do
    Item::ALL.each do |name|
      assert(Item.id(name))
      assert_equal(Item.id(name), Item.id(name.upcase))
      assert_equal(Item.id(name), Item.id(name.downcase))
    end

    assert_raises do
      Item.id('blah')
    end
  end

  test "categorized items returns an array of hashes" do
    assert_equal(Array, Item.categorized_items.class)

    Item.categorized_items.each do |h|
      assert_equal(Hash, h.class)
      assert_equal(1, h.keys.length)
      assert(h[h.keys.first])
    end
  end
end
