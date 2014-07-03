class V1Healthscore < ActiveRecord::Base
  belongs_to :user

  HEALTHSCORE_BASE  = 40
  HEALTHSCORE_NONE  = -9999
  HEALTHSCORE_BASIS = {
                        0  => [0],
                        1  => [3, 3, 3, 2, 2, 1, 1, 0],
                        2  => [8, 0],
                        3  => [4, 0],
                        4  => [2, 2, 1, 1, 1, -1],
                        5  => [1, 1, 1, 1, 1, 0],
                        6  => [2, 2, 1, -1],
                        7  => [1, 1, -1],
                        8  => [-1],
                        9  => [-2],
                        10 => [-3]
                      }

  def self.calculate_part(type, count)
    hs   = 0
    i    = 0

    while ((i < count) and (i < HEALTHSCORE_BASIS[type].length))
      multiplier = 1

      if (1 > (count - i))
        multiplier = (count - i)
      end

      hs += (HEALTHSCORE_BASIS[type][i] * multiplier)

      i += 1
    end

    if (i < count)
      hs += (count - i) * HEALTHSCORE_BASIS[type][-1]
    end

    return hs
  end

  def self.calculate(user_items)
    hs = HEALTHSCORE_NONE
    hs_counts    = {}
    user_items ||= []

    for user_item in user_items
      hs_counts[user_item.item.health_type] ||= 0
      hs_counts[user_item.item.health_type] +=  user_item.count
    end

    hs_counts.each_key do |key|
      if ((0 != key) and (0 != hs_counts[key]))
        if (HEALTHSCORE_NONE == hs)
          hs = HEALTHSCORE_BASE
        end

        hs += Healthscore.calculate_part(key, hs_counts[key])
      end
    end

    return hs
  end

  def self.smart_exists?(user_id, datestr, healthscores)
    if (nil != healthscores)
      if ((false == healthscores.has_key?(datestr)) or (HEALTHSCORE_NONE == healthscores[datestr].value))
        return false
      else
        return true
      end
    end

    return Healthscore.exists?(user_id, datestr)
  end

  def self.exists?(user_id, datestr)
    if (nil == Healthscore.find_by_user_id_and_date(user_id, datestr, :conditions => ["value <> ?", Healthscore::HEALTHSCORE_NONE]))
      return false
    else
      return true
    end
  end
end
