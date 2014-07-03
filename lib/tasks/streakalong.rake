namespace :streakalong do
  desc "Export Database"
  task(:export_database => :environment) do
    for user_item in UserItem.find(:all)
      puts "INSERT INTO user_items (id, date, count, item_id, user_id) VALUES (#{user_item.id}, #{user_item.date}, #{user_item.count}, #{user_item.item_id}, #{user_item.user_id});"
    end

    for hs in Healthscore.find(:all)
      puts "INSERT INTO healthscores (id, date, value, user_id) VALUES (#{hs.id}, #{hs.date}, #{hs.value}, #{hs.user_id});"
    end

    for s in Streak.find(:all)
      puts "INSERT INTO streaks (id, start, end, length, user_id, item_id) VALUES (#{s.id}, #{s.start}, #{s.end}, #{s.length}, #{s.user_id}, #{s.item_id});"
    end
  end
end
