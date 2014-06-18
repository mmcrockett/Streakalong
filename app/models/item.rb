class Item
  FOODS      = ["fruit","vegetable","dairy","grain","protein","fried","sweet","snack","condiment"] 
  BEVERAGES  = ["soda","diet_soda","sports_drink","coffee","tea","juice","water","alcohol"]
  ACTIVITIES = ["walk","run","workout","bicycle","swim"]
  OTHER      = ["weight","tobacco","toothbrush","floss","mouthwash"]
  ALL        = FOODS + BEVERAGES + ACTIVITIES + OTHER

  def self.categorized
    return [{:all => ALL}, {:recent => []}, {:foods => FOODS}, {:beverages => BEVERAGES}, {:activities => ACTIVITIES}, {:other => OTHER}]
  end

  def self.name(id)
    return ALL[id] || ""
  end

  def self.id(name)
    return ALL.index(name) || 0
  end
end
