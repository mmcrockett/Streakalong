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
end
