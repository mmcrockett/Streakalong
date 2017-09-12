class Streak < ActiveRecord::Base
  belongs_to :user
  before_save :calculate_length

  def self.zero_date
    return Time.at(0).to_date()
  end

  def self.base_query(activity)
    return Streak.where("item_id = ?", activity.item_id).where("user_id = ? and length > 0", activity.user_id)
  end

  def self.start_query(activity, date = nil)
    date = activity.date if (nil == date)
    return Streak.base_query(activity).where("start = ?", date).first
  end

  def self.end_query(activity, date = nil)
    date = activity.date if (nil == date)
    return Streak.base_query(activity).where("end = ?", date).first
  end

  def self.between_query(activity)
    return Streak.base_query(activity).where("end > ?", activity.date).where("start < ?", activity.date).first
  end

  def self.remove_streak(activity)
    start_streak = Streak.start_query(activity)
    end_streak   = Streak.end_query(activity)

    if ((nil != start_streak) and (nil != end_streak))
      start_streak.start = Streak.zero_date()
      start_streak.end   = Streak.zero_date()
      start_streak.save!
    elsif ((nil == start_streak) and (nil != end_streak))
      end_streak.end = activity.date.yesterday()
      end_streak.save!
    elsif ((nil != start_streak) and (nil == end_streak))
      start_streak.start = activity.date.tomorrow()
      start_streak.save!
    else
      streak = Streak.between_query(activity)

      if (nil != streak)
        new_streak       = Streak.new(item_id: activity.item_id, user_id: activity.user_id)
        new_streak.start = activity.date.tomorrow()
        new_streak.end   = streak.end
        streak.end       = activity.date.yesterday()
        new_streak.save!
        streak.save!
      end
    end
  end

  def self.add_streak(activity)
    adjacent_next_streak = Streak.start_query(activity, activity.date.tomorrow)
    adjacent_prev_streak = Streak.end_query(activity, activity.date.yesterday)

    if ((nil == adjacent_prev_streak) and (nil == adjacent_next_streak))
      if ((nil == Streak.start_query(activity)) && (nil == Streak.end_query(activity)) && (nil == Streak.between_query(activity)))
        new_streak = Streak.new(start: activity.date, end: activity.date, user_id: activity.user_id, item_id: activity.item_id)
        new_streak.save!
      end
    elsif ((nil != adjacent_prev_streak) and (nil == adjacent_next_streak))
      adjacent_prev_streak.end = activity.date
      adjacent_prev_streak.save!
    elsif ((nil == adjacent_prev_streak) and (nil != adjacent_next_streak))
      adjacent_next_streak.start = activity.date
      adjacent_next_streak.save!
    else
      adjacent_prev_streak.end   = adjacent_next_streak.end
      adjacent_next_streak.start = Streak.zero_date()
      adjacent_next_streak.end   = Streak.zero_date()

      adjacent_prev_streak.save!
      adjacent_next_streak.save!
    end
  end

  def self.process_one(activity)
    if (0 == activity.amount)
      Streak.remove_streak(activity)
    else
      Streak.add_streak(activity)
    end
  end

  def self.process
    latest_streak_date = Streak.maximum(:end)
    activities         = nil

    if (nil == latest_streak_date)
      activities = Activity.all
    else
      activities = Activity.where("updated_at >= ?", latest_streak_date.yesterday())
    end

    activities.each do |activity|
      Streak.process_one(activity)
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
