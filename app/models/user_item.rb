class UserItem < ActiveRecord::Base
  attr_accessible :amount, :date, :item_id
  belongs_to :user
  before_save :non_zero_amount

  def as_json(options = {})
    options[:except] ||= []
    options[:except] << :user_id
    options[:except] << :updated_at
    options[:except] << :created_at
    return super.as_json(options)
  end

  private
  def non_zero_amount 
    if (0 > self.amount)
        self.amount = 0
    end
  end
end
