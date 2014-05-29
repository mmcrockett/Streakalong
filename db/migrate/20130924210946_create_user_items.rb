class CreateUserItems < ActiveRecord::Migration
  def change
    create_table :user_items do |t|
      t.decimal :amount,  :precision => 10, :scale => 2, :null => false
      t.references :user, :null => false
      t.integer :item_id, :null => false
      t.date :date,       :null => false

      t.timestamps
    end
  end
end
