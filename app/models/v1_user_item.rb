class V1UserItem < ActiveRecord::Base
  belongs_to :item
  belongs_to :user

  ROLLING_SIZE    = 15
  LG_ROLLING_SIZE = 30

  def self.get_last_week_total(user_id, item_id, today)
    query = "user_id = ? AND item_id = ? AND date IN (?)"
    day  = today.last_sunday.yesterday
    days = []

    while (false == day.isSunday?())
      days << day.strftime(Calendar::DATE_FORMAT)
      day = day.yesterday()
    end

    days << day.strftime(Calendar::DATE_FORMAT)

    total = UserItem.find(:first, :select => "SUM(count) AS total", :conditions => [query, user_id, item_id, days]).total

    if (nil == total)
      return "0"
    else
      return "#{total}"
    end
  end

  def self.get_data_as_hash(user_id, items, start_date, end_date)
    uitems     = nil
    data       = {}

    uitems = UserItem.get_user_items_and_healthscores_as_hash(user_id, items, start_date, end_date)

    uitems.each_key do |id|
      data[id] = []
    end

    start_date.upto(end_date) do |date|
      datestr  = date.streakstring()

      uitems.each_pair do |key, value|
        if (UserPreference::HEALTHSCORE == key)
          data[key] << UserItem.process_healthscore(value[datestr])
        elsif (Item::WEIGHT_ID == Integer(key))
          data[key] << UserItem.process_weight(value[datestr], data[key][-1])
        else
          data[key] << UserItem.process_value(value[datestr], Healthscore.smart_exists?(user_id, datestr, uitems[UserPreference::HEALTHSCORE]))
        end
      end
    end

    return data
  end

  def self.process_value(data, hsexists)
    val = nil

    if ((nil != data) and (0 < Float(data.count).ceil))
      val = Float(data.count)
    elsif (true == hsexists)
      val = Float(0)
    end

    return val
  end

  def self.process_weight(data, pval = nil)
    val = pval

    if (nil != data)
      if (0 < Float(data.count).ceil)
        val = Float(data.count)
      end
    end

    return val
  end

  def self.process_healthscore(data)
    if ((nil != data) and (Healthscore::HEALTHSCORE_NONE != Float(data.value)))
      return Float(data.value)
    end

    return nil
  end

  def self.get_user_items_as_hash(uid, items, start_date, end_date)
    uitems = {}

    items.each do |id|
      uitems[id] = {}

      UserItem.find_all_by_user_id_and_item_id(uid, id, :conditions => UserItem.get_date_conditions(start_date, end_date)).each do |item|
        uitems[id][String(item.date)] = item
      end
    end

    return uitems
  end

  def self.get_user_items_and_healthscores_as_hash(uid, items, start_date, end_date)
    uitems = UserItem.get_user_items_as_hash(uid, items, start_date, end_date)
    uitems[UserPreference::HEALTHSCORE] = {}

    Healthscore.find_all_by_user_id(uid, :conditions => UserItem.get_date_conditions(start_date, end_date)).each do |hs|
      uitems[UserPreference::HEALTHSCORE][String(hs.date)] = hs
    end

    return uitems
  end

  def self.get_date_conditions(start_date, end_date)
    return ["date >= ? AND date <= ?", start_date.streakstring(), end_date.streakstring()]
  end
end
