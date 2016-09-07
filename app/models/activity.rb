class Activity < ActiveRecord::Base
  belongs_to :user
  validates :amount, :numericality => {:greater_than_or_equal_to => 0}

  LB_TO_KG = 1/2.205

  def weight_at_the_time
    weight = nil

    if (self.item_id == Item.id(:weight))
      weight = self.amount
    else
      weight_activity = self.user.activities
                        .where(:item_id => Item.id(:weight))
                        .where("date <= ?", self.date)
                        .order(:date => :desc)
                        .first

      if (nil != weight_activity)
        weight = weight_activity.amount
      end
    end

    return weight
  end

  def kcalest
    profile = {
      :height => self.user.height,
      :age    => self.user.age,
      :gender => self.user.gender,
      :weight => self.weight_at_the_time
    }

    return CalorieFormula.new(profile).daily_kcal()
  end
end
