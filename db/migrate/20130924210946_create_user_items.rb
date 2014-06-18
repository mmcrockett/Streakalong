class CreateUserItems < ActiveRecord::Migration
  def change
    create_table :user_items do |t|
      t.integer :amount,  :null => false
      t.references :user, :null => false
      t.integer :item_id, :null => false
      t.date :date,       :null => false

      t.timestamps
    end
  end
end
