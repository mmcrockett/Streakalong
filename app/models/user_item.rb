class UserItem < ActiveRecord::Base
  attr_accessible :amount, :date, :item_id
  belongs_to :user
end
