class RenameOldTables < ActiveRecord::Migration
  def change
    rename_table :users, :v1_users
    rename_table :user_items, :v1_user_items
    rename_table :streaks, :v1_streaks
    rename_table :healthscores, :v1_healthscores
    rename_table :items, :v1_items
    rename_table :user_preferences, :v1_user_preferences
  end
end
