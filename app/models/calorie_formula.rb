class CalorieFormula
  GENDER_COMPONENT = {
    :male => 5,
    :female => -161
  }

  DEFAULT_WEIGHT_IN_KG = 80
  WEIGHT_COMPONENT     = 10

  DEFAULT_HEIGHT_IN_CM = 175
  HEIGHT_COMPONENT     = 6.25

  DEFAULT_AGE          = 30
  AGE_COMPONENT        = -5

  SEDENTARY_ACTIVITY_MULTIPLIER = 1.2

  def initialize(params = {})
    @gender = params[:gender]
    @weight = params[:weight] || DEFAULT_WEIGHT_IN_KG
    @height = params[:height] || DEFAULT_HEIGHT_IN_CM
    @age    = params[:age]    || DEFAULT_AGE
  end

  def gender_component
    gender_component = GENDER_COMPONENT[@gender]
    if (nil == gender_component)
      gender_component = 0

      GENDER_COMPONENT.values.each do |v|
        gender_component += v
      end

      gender_component = gender_component / GENDER_COMPONENT.size
    end

    return gender_component
  end

  def weight_component
    return (@weight * WEIGHT_COMPONENT)
  end

  def height_component
    return (@height * HEIGHT_COMPONENT)
  end

  def age_component
    return (@age * AGE_COMPONENT)
  end

  def daily_kcal
    return -((self.weight_component + self.height_component + self.age_component + self.gender_component) * SEDENTARY_ACTIVITY_MULTIPLIER).ceil.round(-1)
  end
end
