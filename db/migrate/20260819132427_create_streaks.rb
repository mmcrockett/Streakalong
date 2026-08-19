class CreateStreaks < ActiveRecord::Migration[8.1]
  def change
    create_table :streaks do |t|
      t.date :start, null: false
      t.date :end, null: false
      t.integer :length, null: false
      t.integer :item_id, null: false
      t.integer :user_id, null: false
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
