require 'test_helper'

class PreferenceTest < ActiveSupport::TestCase
  def setup
    @defaults = JSON.parse(Preference::DEFAULTS.to_json)
  end

  test "create defaults on new" do
    p = Preference.new
    assert_equal(@defaults.to_json, p.to_json)
  end

  test "should serialize to json" do
    p = Preference.new
    assert_equal(@defaults.to_json, p.to_json)
  end

  test "load from json string creates a new object merged with defaults" do
    non_default = {Preference::ITEM_TAB => 'other', Preference::RECENT => [1,2,3]}
    p = Preference.load("#{non_default.to_json}")
    assert_equal(@defaults.merge(non_default).to_json, p.to_json)
  end

  test "dump produces json" do
    non_default = {Preference::ITEM_TAB => 'other', Preference::RECENT => [1,2,3]}
    p = Preference.load("#{non_default.to_json}")
    assert_equal(@defaults.merge(non_default).to_json, Preference.dump(p))
  end

  test "non hash is ignored" do
    p = Preference.new("hello")
    assert_equal(@defaults.to_json, p.to_json)
  end

  test "internal state can't be altered by read" do
    p = Preference.new
    a = p[Preference::RECENT]
    a << [2,1,3]
    assert_equal(@defaults.to_json, p.to_json)
  end

  test "item_tab, units and recent allow [] assignments" do
    p = Preference.new
    p[Preference::RECENT] = [3]
    p[Preference::ITEM_TAB] = 'other'
    p[Preference::UNITS] = Preference::VALID_UNITS.last
    assert_equal([3], p.recent)
    assert_equal('other', p.item_tab)
    assert_equal("#{Preference::VALID_UNITS.last}", p.units)
  end

  test "item_tab, units and recent allow assignments" do
    p = Preference.new
    p.recent = [3]
    p.item_tab = 'other'
    p.units    = Preference::VALID_UNITS.last
    assert_equal([3], p.recent)
    assert_equal('other', p.item_tab)
    assert_equal("#{Preference::VALID_UNITS.last}", p.units)
  end

  test "during assignment classes must match or they're ignored" do
    p = Preference.new

    p.recent = 3
    p.item_tab = 9
    p.units    = 9

    assert_equal([], p.recent)
    assert_equal("all", p.item_tab)
    assert_equal("imperial", p.units)
  end

  test "imperial? and metric? return correct values" do
    p = Preference.new

    assert(p.imperial?)
    assert_not(p.metric?)

    p.units = Preference::METRIC_UNITS

    assert(p.metric?)
    assert_not(p.imperial?)
  end

  test "units only takes known types as values and ignoring others" do
    p = Preference.new

    Preference::VALID_UNITS.each do |type|
      p.units = type
      assert_equal("#{type}", p.units)
    end

    v = p.units
    p.units = "notvalid"
    assert_equal(v, p.units)
  end

  test "item_tab only takes known categories as values and ignoring others" do
    p = Preference.new
    p.item_tab = "other"

    Item.categorized_items.each do |category|
      p.item_tab = category.keys.first
      assert_equal("#{category.keys.first}", p.item_tab)
    end

    v = p.item_tab
    p.item_tab = "notvalid"
    assert_equal(v, p.item_tab)
  end

  test "adding recent with recent function only keeps the max recent number of entries" do
    p = Preference.new
    new_recent = []

    (Preference::MAX_RECENT + 1).times do |i|
      new_recent << i
    end

    p.recent = new_recent
    assert_equal(Preference::MAX_RECENT, p.recent.length)
  end

  test "adding recent with []= function only keeps the max recent number of entries" do
    p = Preference.new
    new_recent = []

    (Preference::MAX_RECENT + 1).times do |i|
      new_recent << i
    end

    p[Preference::RECENT] = new_recent
    assert_equal(Preference::MAX_RECENT, p.recent.length)
  end

  test "adding item_tab with []= function only allows known item tabs." do
    p = Preference.new
    p[Preference::ITEM_TAB] = "other"

    Item.categorized_items.each do |category|
      p[Preference::ITEM_TAB] = category.keys.first
      assert_equal("#{category.keys.first}", p.item_tab)
    end

    v = p.item_tab
    p[Preference::ITEM_TAB] = "notvalid"
    assert_equal(v, p[Preference::ITEM_TAB])
  end

  test "adding unknown preferences with []= function is ignored." do
    p = Preference.new
    p['mytab'] = "blah"

    assert_nil(p['mytab'])
  end

  test "preferredTab returns whether we are on the preferred tab by name or symbol" do
    p = Preference.new
    assert(p.preferredTab?("all"))
    assert(p.preferredTab?(:all))
    assert(!p.preferredTab?("notmytab"))
    assert(!p.preferredTab?(:notmytab))
  end

  test "preferredTab fails on non-string, non-symbol" do
    p = Preference.new

    assert_raises do
      assert(p.preferredTab?([]))
    end
  end

  test "don't allow unknown preferences" do
    p = Preference.new({:a => 'xxx'})
    p[:b] = 'yyy'
    o = Preference.load("#{{:c => 'zzz'}.to_json}")

    assert_nil(p[:a])
    assert_nil(p[:b])
    assert_nil(o[:c])
  end
end
