namespace :streakalong do
  desc "Export Database"
  task(:export_database => :environment) do
    for activity in Activity.all
      puts "INSERT INTO activities (id, date, amount, item_id, user_id) VALUES (#{activity.id}, #{activity.date}, #{activity.amount}, #{activity.item_id}, #{activity.user_id});"
    end

    for s in Streak.all
      puts "INSERT INTO streaks (id, start, end, length, user_id, item_id) VALUES (#{s.id}, #{s.start}, #{s.end}, #{s.length}, #{s.user_id}, #{s.item_id});"
    end
  end

  desc "Process Streaks"
  task(:process_streaks => :environment) do
    Streak.process
  end
end
