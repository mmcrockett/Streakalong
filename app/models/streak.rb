class Streak < ActiveRecord::Base
  attr_accessible :end, :length, :start
  belongs_to :user
  before_save :calculate_length

  STREAK_BASE_QUERY    = "item_id = ? AND user_id = ?"
  STREAK_BASE_NL_QUERY = "#{STREAK_BASE_QUERY} AND length > 0"

  def self.zero_date
    return Time.at(0).to_date()
  end

  def self.remove_streak(user_id, item_id, date)
    start_streak = Streak.where("#{STREAK_BASE_NL_QUERY} AND start = ?", item_id, user_id, date).first
    end_streak   = Streak.where("#{STREAK_BASE_NL_QUERY} AND end   = ?", item_id, user_id, date).first

    if ((nil != start_streak) and (nil != end_streak))
      start_streak.start  = Streak.zero_date()
      start_streak.end    = Streak.zero_date()
      start_streak.save()
    elsif ((nil == start_streak) and (nil != end_streak))
      end_streak.end     = date.yesterday()
      end_streak.save()
    elsif ((nil != start_streak) and (nil == end_streak))
      start_streak.start   = date.tomorrow()
      start_streak.save()
    else
      streak = Streak.where("#{STREAK_BASE_NL_QUERY} AND start < ? AND end > ?", item_id, user_id, date, date).first
      new_streak        = Streak.new(:item_id => item_id, :user_id => user_id)
      new_streak.start  = date.tomorrow()
      new_streak.end    = streak.end
      streak.end        = date_obj.yesterday()
      new_streak.save()
      streak.save()
    end
  end

  def self.add_streak(user_id, item_id, date)
    next_streak = Streak.where("#{STREAK_BASE_NL_QUERY} AND start = ?", item_id, user_id, date.tomorrow()).first
    prev_streak = Streak.where("#{STREAK_BASE_NL_QUERY} AND end   = ?", item_id, user_id, date.yesterday()).first

    if ((nil == prev_streak) and (nil == next_streak))
      new_streak = Streak.new(:start => date, :end => date)
      new_streak.user_id = user_id
      new_streak.item_id = item_id
      new_streak.save()
    elsif ((nil != prev_streak) and (nil == next_streak))
      prev_streak.end = date
      prev_streak.save()
    elsif ((nil == prev_streak) and (nil != next_streak))
      next_streak.start = date
      next_streak.save()
    else
      prev_streak.end     = next_streak.end
      next_streak.start   = Streak.zero_date()
      next_streak.end     = Streak.zero_date()

      prev_streak.save()
      next_streak.save()
    end
  end

  private
  def calculate_length
    if ((Streak.zero_date == self.start) || (Streak.zero_date == self.end))
      self.length = 0
    else
      self.length = self.end - self.start + 1
    end
  end
end
