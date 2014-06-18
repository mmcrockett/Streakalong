class UserItem < ActiveRecord::Base
  attr_accessible :amount, :date, :item_id
  belongs_to :user

  def as_json(options = {})
    options[:except] ||= []
    options[:except] << :user_id
    options[:except] << :updated_at
    options[:except] << :created_at
    return super.as_json(options)
  end
end
