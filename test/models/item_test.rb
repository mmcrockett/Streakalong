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

  test "symbol gets translated to string" do
    Item::ALL.each do |name|
      name_sym = name.to_sym
      assert_not_equal(name_sym, name)
      assert(name_sym.to_s == name)
      assert(Item.id(name_sym))
      assert_equal(Item.id(name_sym), Item.id(name.upcase.to_sym))
      assert_equal(Item.id(name_sym), Item.id(name.downcase.to_sym))
    end
  end

  test "kcal returns valid data for all types." do
    Item::ALL.each do |name|
      assert(-300 <= Item.kcal(name))
    end
  end
end
