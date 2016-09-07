class Activity < ActiveRecord::Base
  belongs_to :user
  validates :amount, :numericality => {:greater_than_or_equal_to => 0}

  LB_IN_KG = 2.205

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

    if ((nil != weight) && (true == self.user.preferences.imperial?))
      weight = (weight / LB_IN_KG).ceil
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
