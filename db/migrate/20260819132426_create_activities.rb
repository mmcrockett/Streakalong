class CreateActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :activities do |t|
      t.integer :amount, null: false
      t.integer :user_id
      t.integer :item_id, null: false
      t.date :date, null: false

      t.timestamps
    end

    add_index :activities, :user_id
  end
end
