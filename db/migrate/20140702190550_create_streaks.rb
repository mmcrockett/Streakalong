class CreateStreaks < ActiveRecord::Migration
  def change
    create_table :streaks do |t|
      t.date :start,     :null => false
      t.date :end,       :null => false
      t.integer :length, :null => false
      t.integer :item_id, :null => false
      t.references :user, :null => false

      t.timestamps
    end
  end
end
