class CalorieFormulaTest < ActiveSupport::TestCase
  test "If no values use defaults" do
    assert_equal(2000, CalorieFormula.new().daily_kcal)
  end

  test "It uses 'ceil' and round to the 10s digit" do
    age = 20
    height = 150
    weight = 60
    gender = :male
    person = CalorieFormula.new({:height => height, :weight => weight, :age => age, :gender => gender})
    unrounded_expectation  = height * CalorieFormula::HEIGHT_COMPONENT
    unrounded_expectation += weight * CalorieFormula::WEIGHT_COMPONENT
    unrounded_expectation += age * CalorieFormula::AGE_COMPONENT
    unrounded_expectation += CalorieFormula::GENDER_COMPONENT[gender]
    unrounded_expectation *= CalorieFormula::SEDENTARY_ACTIVITY_MULTIPLIER

    assert(unrounded_expectation != person.daily_kcal)
    assert_equal(unrounded_expectation.ceil.round(-1), person.daily_kcal)
  end

  test "gender is honored" do
    male   = CalorieFormula.new({:gender => :male})
    female = CalorieFormula.new({:gender => :female})
    diff   = CalorieFormula::GENDER_COMPONENT[:female] - CalorieFormula::GENDER_COMPONENT[:male]
    assert_equal(male.gender_component + diff,female.gender_component)
  end

  test "age is honored" do
    person1 = CalorieFormula.new({:age => 30})
    person2 = CalorieFormula.new({:age => 31})
    diff = CalorieFormula::AGE_COMPONENT
    assert_equal(person1.age_component + diff,person2.age_component)
  end

  test "height is honored" do
    person1 = CalorieFormula.new({:height => 160})
    person2 = CalorieFormula.new({:height => 161})
    diff = CalorieFormula::HEIGHT_COMPONENT
    assert_equal(person1.height_component + diff,person2.height_component)
  end

  test "weight is honored" do
    person1 = CalorieFormula.new({:weight => 60})
    person2 = CalorieFormula.new({:weight => 61})
    diff = CalorieFormula::WEIGHT_COMPONENT
    assert_equal(person1.weight_component + diff,person2.weight_component)
  end

  test "If gender is unknown use mean of values" do
    expected_value = 0
    CalorieFormula::GENDER_COMPONENT.values.each do |v|
      expected_value += v
    end
    expected_value = (expected_value/CalorieFormula::GENDER_COMPONENT.size)

    assert_equal(expected_value, CalorieFormula.new({:gender => :blah}).gender_component)
    assert_equal(expected_value, CalorieFormula.new().gender_component)
  end
end
