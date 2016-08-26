require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  def setup
    @activity = activities(:one)
  end

  test "amount must be greater than or equal to zero" do
    @activity.amount = -1
    @activity.save
    assert(@activity.errors.messages.include?(:amount))
    assert_equal("must be greater than or equal to 0", @activity.errors.messages[:amount].first)
  end

  test "kcalest returns default if no weight found" do
    assert_equal(CalorieFormula.new.daily_kcal, @activity.kcalest)
  end

  test "weight gets latest weight" do
    user = users(:two)
    activity_2016_06_25 = activities(:u2_a0)
    weight_activity_2016_07_01 = activities(:u2_w0)
    activity_2016_07_02 = activities(:u2_a1)
    weight_activity_2016_07_10 = activities(:u2_w1)
    activity_2016_07_12 = activities(:u2_a2)

    assert_equal(nil, activity_2016_06_25.weight_at_the_time)
    assert_equal(90, weight_activity_2016_07_01.weight_at_the_time)
    assert_equal(90, activity_2016_07_02.weight_at_the_time)
    assert_equal(60, weight_activity_2016_07_10.weight_at_the_time)
    assert_equal(60, activity_2016_07_12.weight_at_the_time)
  end

  test "kcalest returns calculation for weight" do
    user = users(:two)
    activity_2016_06_25 = activities(:u2_a0)
    weight_activity_2016_07_01 = activities(:u2_w0)
    activity_2016_07_02 = activities(:u2_a1)
    weight_activity_2016_07_10 = activities(:u2_w1)
    activity_2016_07_12 = activities(:u2_a2)
    user_calorie_default_kg = CalorieFormula.new({:height => user.height, :gender => user.gender, :age => user.age})
    user_calorie_90kg       = CalorieFormula.new({:height => user.height, :gender => user.gender, :age => user.age, :weight => 90})
    user_calorie_60kg       = CalorieFormula.new({:height => user.height, :gender => user.gender, :age => user.age, :weight => 60})

    assert_equal(user_calorie_default_kg.daily_kcal, activity_2016_06_25.kcalest)
    assert_equal(user_calorie_90kg.daily_kcal, weight_activity_2016_07_01.kcalest)
    assert_equal(user_calorie_90kg.daily_kcal, activity_2016_07_02.kcalest)
    assert_equal(user_calorie_60kg.daily_kcal, weight_activity_2016_07_10.kcalest)
    assert_equal(user_calorie_60kg.daily_kcal, activity_2016_07_12.kcalest)
  end
end
