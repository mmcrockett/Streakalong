class MigrateOldTables < ActiveRecord::Migration
  def up
    for user_old in V1User.find(:all)
      if ("Demo" != user_old.name)
        user_items_old = V1UserItem.where("user_id = ? AND count <> 0", user_old.id)

        if (0 != user_items_old.size)
          user_new = User.new()
          user_new.name            = user_old.name
          user_new.username        = user_old.username
          user_new.hashed_password = user_old.hashed_password
          user_new.salt            = user_old.salt
          user_new.created_at      = user_old.created_login
          user_new.preferences     = UserPreference::DEFAULTS

          if (false == user_new.save(:validate => false))
            raise "!ERROR: Unable to save user. #{user_new.errors.full_messages}"
          end

          for user_item_old in user_items_old
            user_item_new = UserItem.new()
            user_item_new.amount  = user_item_old.count.to_i
            user_item_new.user_id = user_new.id
            user_item_new.item_id = Item.id(V1Item.find(user_item_old.item_id).title)
            user_item_new.date    = Date.strptime("#{user_item_old.date}", "%Y%m%d")

            if (false == user_item_new.save())
              raise "!ERROR: Unable to save user item. #{user_item_new.errors.full_messages}."
            end
          end
        end
      end
    end
  end

  def down
  end
end
