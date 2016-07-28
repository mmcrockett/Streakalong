class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :amount, :null => false
      t.references :user, index: true, foreign_key: true
      t.integer :item_id, :null => false
      t.date :date, :null => false

      t.timestamps null: false
    end
  end
end
