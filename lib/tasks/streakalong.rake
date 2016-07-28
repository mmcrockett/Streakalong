namespace :streakalong do
  desc "Export Database"
  task(:export_database => :environment) do
    for user_item in UserItem.all
      puts "INSERT INTO user_items (id, date, amount, item_id, user_id) VALUES (#{user_item.id}, #{user_item.date}, #{user_item.amount}, #{user_item.item_id}, #{user_item.user_id});"
    end

    for s in Streak.all
      puts "INSERT INTO streaks (id, start, end, length, user_id, item_id) VALUES (#{s.id}, #{s.start}, #{s.end}, #{s.length}, #{s.user_id}, #{s.item_id});"
    end
  end

  desc "QA New Streaks"
  task(:qa_streaks => :environment) do
    v1_streak_length_exceptions   = [214,258,293]
    v1_streak_middling_exceptions = [305,3994,2668,4002]
    v1_streak_combine_exceptions = [147,148,390,392,468,481,2435,2436,4547,4548,4210,4221,2563,2582,2620,2621,2912,2931,3829,3868,3829,3868]
    v1_streak_exceptions = v1_streak_length_exceptions + v1_streak_middling_exceptions + v1_streak_combine_exceptions
    new_streak_exceptions = [5258,5290,5373,5450,7296,9356,9019,7422,7478,7768,8667,8667,5164]
    new_streak_ids = Streak.where("length <> 0 AND end >= '2014-07-01'").pluck(:id) - new_streak_exceptions
    errors = []
    for v1_user in V1User.find(:all)
      if ("Demo" != v1_user.name)
        v1_streaks = V1Streak.where("length > 0  AND end >= 20140701 AND user_id = ?", v1_user.id)
        new_user = User.where("username = ?", v1_user.username).first

        puts "Checking '#{v1_streaks.count} old streaks...'"
        v1_streaks.each do |v1_streak|
          new_item_id = Item.id(V1Item.find(v1_streak.item_id).title)
          start_date = V1Streak.get_date_obj(v1_streak.start)
          end_date   = V1Streak.get_date_obj(v1_streak.end)
          streak = Streak.where("start = ? AND end = ? and item_id = ? and length = ? and user_id = ?", start_date, end_date, new_item_id, v1_streak.length, new_user.id).first

          if (nil == streak)
            if (false == v1_streak_exceptions.include?(v1_streak.id))
              err  = "!ERROR:"
              err << " SELECT * FROM v1_streaks WHERE item_id=#{v1_streak.item_id} AND user_id=#{v1_user.id} AND start >= #{v1_streak.start} and start <= #{v1_streak.end};"
              err << " SELECT * FROM streaks WHERE item_id=#{new_item_id} AND user_id=#{new_user.id} AND start >= '#{start_date}' and start <= '#{end_date}';"
              errors << err
            end
          else
            new_streak_ids.delete(streak.id)
          end
        end
      end
    end

    if (false == errors.empty?())
      errors.each do |error|
        puts "#{error}"
      end
      raise "There were errors."
    end

    if (false == new_streak_ids.empty?())
      raise "!ERROR: Remaining unverified streaks #{new_streak_ids}."
    end
  end

  desc "Process Streaks"
  task(:process_streaks => :environment) do
    latest_streak_date = Streak.maximum(:end)
    user_items         = nil

    if (nil == latest_streak_date)
      user_items = UserItem.all
    else
      user_items = UserItem.where("updated_at >= ?", latest_streak_date.yesterday())
    end

    user_items.each do |user_item|
      if (0 == user_item.amount)
        Streak.remove_streak(user_item.user_id, user_item.item_id, user_item.date)
      else
        Streak.add_streak(user_item.user_id, user_item.item_id, user_item.date)
      end
    end
  end
end
