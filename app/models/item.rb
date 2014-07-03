class Item
  FOODS      = ["fruit","vegetable","dairy","grain","protein","fried","sweet","snack","condiment"] 
  BEVERAGES  = ["soda","diet_soda","sports_drink","coffee","tea","juice","water","alcohol"]
  ACTIVITIES = ["walk","run","workout","bicycle","swim"]
  OTHER      = ["weight","tobacco","toothbrush","floss","mouthwash"]
  ALL        = FOODS + BEVERAGES + ACTIVITIES + OTHER

  def self.name(id)
    name = ALL[id]

    if (nil == name)
      raise "!ERROR: Couldn't find item with id:'#{id}'."
    end

    return name
  end

  def self.id(name)
    name.downcase!

    if ("breads & grains" == name)
      id = ALL.index("grain")
    elsif ("snacks" == name)
      id = ALL.index("snack")
    elsif ("sweets" == name)
      id = ALL.index("sweet")
    elsif ("meats, beans & proteins" == name)
      id = ALL.index("protein")
    elsif ("Sauces, Oils & Butter".downcase == name)
      id = ALL.index("condiment")
    elsif ("Work Out".downcase == name)
      id = ALL.index("workout")
    elsif ("sports drink" == name)
      id = ALL.index("sports_drink")
    else
      id = ALL.index(name)
    end

    if (nil == id)
      raise "!ERROR: Couldn't find item with name:'#{name}'."
    end

    return id
  end
end
