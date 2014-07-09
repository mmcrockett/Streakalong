class V1Streak < ActiveRecord::Base
  belongs_to :item
  belongs_to :user

  STREAK_BASE_QUERY    = "item_id = ? AND user_id = ?"
  STREAK_BASE_NL_QUERY = "#{STREAK_BASE_QUERY} AND length > 0"
  STREAK_DATE_FORMAT   = "%b %e %Y"

  def self.find_max_streak(user_id, item_id)
    max_length = Streak.find(:first, :select => "MAX(length) AS max", :conditions => [STREAK_BASE_QUERY, item_id, user_id]).max
    streak = nil

    if (nil != max_length)
      streaks = Streak.find_all_by_user_id_and_item_id_and_length(user_id, item_id, max_length)

      if (1 == streaks.size())
        streak = streaks.first
      else
        max_date = Streak.find(:first, :select => "MAX(end) AS mend", :conditions => [STREAK_BASE_QUERY + " AND length = ?", item_id, user_id, max_length]).mend
        streak = Streak.find_by_user_id_and_item_id_and_length_and_end(user_id, item_id, max_length, max_date)
      end
    end

    return Streak.validate(streak)
  end

  def self.find_recent_streak(user_id, item_id)
    max_date = Streak.find(:first, :select => "MAX(end) AS mend", :conditions => [STREAK_BASE_QUERY, item_id, user_id]).mend

    if (nil == max_date)
      return nil
    else
      return Streak.validate(Streak.find_by_user_id_and_item_id_and_end(user_id, item_id, max_date))
    end
  end

  def self.validate(streak)
    if (nil != streak)
      if ((0 == streak.end) or (0 == streak.end))
        streak = nil
      end
    end

    return streak
  end

  def self.get_date_obj(integer_date)
    if (true == integer_date.is_a?(Date))
      return integer_date
    else
      date_str = String(integer_date)[0, 4] + "-" + String(integer_date)[4, 2] + "-" + String(integer_date)[6, 2]
      date_obj = Date.strptime(date_str, "%Y-%m-%d")

      return date_obj
    end
  end
end
