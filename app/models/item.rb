class Item
  FOODS      = ["fruit","vegetable","dairy","grain","protein","fried","sweet","snack","condiment"] 
  BEVERAGES  = ["soda","diet_soda","sports_drink","coffee","tea","juice","water","alcohol"]
  ACTIVITIES = ["walk","run","workout","bicycle","swim"]
  OTHER      = ["weight","tobacco","toothbrush","floss","mouthwash"]
  ALL        = FOODS + BEVERAGES + ACTIVITIES + OTHER
  CALORIES   = {
                 "fruit"        => 80,
                 "vegetable"    => 40,
                 "dairy"        => 140,
                 "grain"        => 140,
                 "protein"      => 120,
                 "fried"        => 50,
                 "sweet"        => 250,
                 "snack"        => 150,
                 "condiment"    => 25,
                 "soda"         => 150,
                 "diet_soda"    => 0,
                 "sports_drink" => 125,
                 "coffee"       => 40,
                 "tea"          => 25,
                 "juice"        => 120,
                 "water"        => 0,
                 "alcohol"      => 150,
                 "walk"         => -100,
                 "run"          => -200,
                 "workout"      => -150,
                 "bicycle"      => -200,
                 "swim"         => -200,
                 "weight"       => 0,
                 "tobacco"      => 0,
                 "toothbrush"   => 0,
                 "floss"        => 0,
                 "mouthwash"    => 0
  }

  def self.name(id)
    name = ALL[id]

    if (nil == name)
      raise "!ERROR: Couldn't find item with id:'#{id}'."
    end

    return name
  end

  def self.id(name)
    if (true == name.is_a?(Symbol))
      name = name.to_s
    end

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

  def self.kcal(name)
    return CALORIES[name]
  end

  def self.categorized_items
    categorized_items = []
    categorized_items << {:all => Item::ALL}
    categorized_items << {Preference::RECENT => Item::ALL}
    categorized_items << {:foods  => Item::FOODS}
    categorized_items << {:beverages  => Item::BEVERAGES}
    categorized_items << {:activities => Item::ACTIVITIES}
    categorized_items << {:other => Item::OTHER}

    return categorized_items
  end
end
