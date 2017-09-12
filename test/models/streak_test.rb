require 'test_helper'

class StreakTest < ActiveSupport::TestCase
  def setup
    @user = User.new(username: 'abc123', password: '123abc', name: 'streakuser')
    @user.save!
    @week_ago = Date.today.days_ago(7).to_date
  end

  def add_activity(params = {})
    @user.activities << Activity.new({amount: 10, item_id: 1, date: @week_ago}.merge(params))
    @user.save!
    @user.reload
  end

  def process_streaks
    Streak.process()

    return Streak.where(user: @user)
  end

  test "can build a streak" do
    add_activity
    results = process_streaks

    assert_equal(1, results.size)
    assert_equal(1, results.first.length)
    assert_equal(@week_ago, results.first.start)
    assert_equal(@week_ago, results.first.end)
  end

  test "can append to a streak" do
    add_activity
    results = process_streaks
    add_activity(date: @week_ago.tomorrow)
    add_activity(date: @week_ago.tomorrow.tomorrow)
    results = process_streaks

    assert_equal(1, results.size)
    assert_equal(3, results.first.length)
    assert_equal(@week_ago, results.first.start)
    assert_equal(@week_ago.tomorrow.tomorrow, results.first.end)
  end

  test "can prepend a streak" do
    add_activity(date: @week_ago.tomorrow.tomorrow)
    results = process_streaks
    add_activity(date: @week_ago.tomorrow)
    add_activity
    results = process_streaks

    assert_equal(1, results.size)
    assert_equal(3, results.first.length)
    assert_equal(@week_ago, results.first.start)
    assert_equal(@week_ago.tomorrow.tomorrow, results.first.end)
  end

  test "can combine two streaks" do
    add_activity
    add_activity(date: @week_ago.tomorrow.tomorrow)
    results = process_streaks
    add_activity(date: @week_ago.tomorrow)
    results = process_streaks

    assert_equal(2, results.size)
    assert_equal(3, results.first.length)
    assert_equal(0, results.last.length)
    assert_equal(Streak.zero_date, results.last.start)
    assert_equal(Streak.zero_date, results.last.end)
    assert_equal(@week_ago, results.first.start)
    assert_equal(@week_ago.tomorrow.tomorrow, results.first.end)
  end

  test "can remove a streak" do
    add_activity
    results = process_streaks
    activity = @user.activities.first
    activity.amount = 0
    activity.save!
    results = process_streaks

    assert_equal(1, results.size)
    assert_equal(0, results.first.length)
    assert_equal(Streak.zero_date, results.first.start)
    assert_equal(Streak.zero_date, results.first.end)
  end

  test "can shorten front of a streak" do
    add_activity
    add_activity(date: @week_ago.tomorrow)
    add_activity(date: @week_ago.tomorrow.tomorrow)
    results = process_streaks
    activity = @user.activities.first
    activity.amount = 0
    activity.save!
    results = process_streaks

    assert_equal(1, results.size)
    assert_equal(2, results.first.length)
    assert_equal(@week_ago.tomorrow, results.first.start)
    assert_equal(@week_ago.tomorrow.tomorrow, results.first.end)
  end

  test "can shorten back of a streak" do
    add_activity
    add_activity(date: @week_ago.tomorrow)
    add_activity(date: @week_ago.tomorrow.tomorrow)
    results = process_streaks
    assert_equal(1, results.size)
    activity = @user.activities.last
    activity.amount = 0
    activity.save!
    results = process_streaks

    assert_equal(1, results.size)
    assert_equal(2, results.first.length)
    assert_equal(@week_ago, results.first.start)
    assert_equal(@week_ago.tomorrow, results.first.end)
  end

  test "can split a streak" do
    add_activity
    add_activity(date: @week_ago.tomorrow)
    add_activity(date: @week_ago.tomorrow.tomorrow)
    results = process_streaks
    assert_equal(1, results.size)
    activity = @user.activities[1]
    activity.amount = 0
    activity.save!
    results = process_streaks

    assert_equal(2, results.size)
    assert_equal(1, results.first.length)
    assert_equal(1, results.last.length)
    assert_equal(@week_ago, results.first.start)
    assert_equal(@week_ago, results.first.end)
    assert_equal(@week_ago.tomorrow.tomorrow, results.last.start)
    assert_equal(@week_ago.tomorrow.tomorrow, results.last.end)
  end

  test "no need to split if the zero amount at end is not in a streak" do
    add_activity
    add_activity(date: @week_ago.tomorrow)
    results = process_streaks
    add_activity(date: @week_ago.tomorrow.tomorrow, amount: 0)
    results = process_streaks

    assert_equal(1, results.size)
    assert_equal(2, results.first.length)
    assert_equal(@week_ago, results.first.start)
    assert_equal(@week_ago.tomorrow, results.first.end)
  end

  test "no need to split if the zero amount at beginning is not in a streak" do
    add_activity(date: @week_ago.tomorrow)
    add_activity(date: @week_ago.tomorrow.tomorrow)
    results = process_streaks
    add_activity(amount: 0)
    results = process_streaks

    assert_equal(1, results.size)
    assert_equal(2, results.first.length)
    assert_equal(@week_ago.tomorrow, results.first.start)
    assert_equal(@week_ago.tomorrow.tomorrow, results.first.end)
  end
end
