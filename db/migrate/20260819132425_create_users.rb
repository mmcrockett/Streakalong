class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :username, null: false
      t.string :hashed_password, null: false
      t.string :salt, null: false
      t.string :preferences, null: false
      t.date :birthday
      t.string :gender
      t.integer :height

      t.timestamps
    end
  end
end
