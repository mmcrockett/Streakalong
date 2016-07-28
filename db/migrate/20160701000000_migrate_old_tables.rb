class MigrateOldTables < ActiveRecord::Migration
  def up
    migrated_count = 0
    old_count      = V1UserItem.where("count <> 0 and user_id <> -1").count

    V1User.all.each do |user_old|
      activity_migrated_count = 0
      user_items_old = V1UserItem.where("user_id = ? AND count <> 0", user_old.id)

      if (0 != user_items_old.size)
        if ("Demo" != user_old.name)
          user_new = User.new()
          user_new.name            = user_old.name
          user_new.username        = user_old.username
          user_new.hashed_password = user_old.hashed_password
          user_new.salt            = user_old.salt
          user_new.created_at      = user_old.created_login

          if (false == user_new.save(:validate => false))
            raise "!ERROR: Unable to save user. #{user_new.errors.full_messages}"
          end

          for user_item_old in user_items_old
            activity = Activity.new()
            activity.amount  = user_item_old.count.ceil
            activity.user_id = user_new.id
            activity.item_id = Item.id(V1Item.find(user_item_old.item_id).title)
            activity.date    = Date.strptime("#{user_item_old.date}", "%Y%m%d")

            if (false == activity.save())
              raise "!ERROR: Unable to save user item. #{activity.errors.full_messages}."
            else
              activity_migrated_count += 1
            end
          end
        else
          activity_migrated_count = user_items_old.size
        end
      end

      migrated_count += activity_migrated_count

      if (0 != user_items_old.size)
        puts "Processed '#{user_old.id}':'#{user_items_old.size}':'#{activity_migrated_count}':'#{migrated_count}'."
      end
    end

    if (migrated_count != old_count)
      raise "!ERROR: Counts don't match '#{migrated_count}' vs '#{old_count}'."
    end
  end

  def down
  end
end
