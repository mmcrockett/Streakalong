class Preference
  ITEM_TAB = 'item_tab'
  RECENT   = 'recent'
  UNITS    = 'units'
  MAX_RECENT = 16

  IMPERIAL_UNITS = :imperial.to_s
  METRIC_UNITS   = :metric.to_s

  VALID_UNITS = [IMPERIAL_UNITS, METRIC_UNITS]

  DEFAULTS = {
    ITEM_TAB => :all,
    RECENT   => [],
    UNITS    => VALID_UNITS.first
  }

  def initialize(values = {})
    if ((true == values.is_a?(String)) && (true == values.include?("{")))
      values = JSON.parse(values)
    end

    if (false == values.is_a?(Hash))
      Rails.logger.warn("Trying to initialize preference with non-hash '#{values.class}':'#{values}'.")
      values = {}
    end

    @preferences = JSON.parse(Preference::DEFAULTS.to_json)

    values.each do |k,v|
      self[k] = v
    end
  end

  def []=(k,v)
    k = "#{k}"

    if ("#{Preference::ITEM_TAB}" == k)
      self.item_tab = v
    elsif ("#{Preference::RECENT}" == k)
      self.recent = v
    elsif ("#{Preference::UNITS}" == k)
      self.units = v
    else
      Rails.logger.warn("Ignoring key that isn't a known preference '#{k}'.")
    end

    return self
  end

  def [](k)
    k = "#{k}"

    if (false == @preferences.include?(k))
      return nil
    else
      return JSON.parse(@preferences.to_json)[k]
    end
  end

  def to_json
    @preferences.to_json
  end

  def units
    return self[Preference::UNITS]
  end

  def units=(v)
    v = "#{v}"

    if (true == matching_type?(Preference::UNITS, v))
      if (true == VALID_UNITS.include?(v))
        @preferences[Preference::UNITS] = v
      else
        Rails.logger.warn("Ignoring units because invalid unit type '#{v}'.")
      end
    end

    return self
  end

  def metric?
    return (:metric == self.units)
  end

  def item_tab=(v)
    v = "#{v}"

    if (true == matching_type?(Preference::ITEM_TAB, v))
      Item.categorized_items.each do |category|
        if ("#{category.keys.first}" == "#{v}")
          @preferences[Preference::ITEM_TAB] = v
          break
        end
      end

      if (v != self[Preference::ITEM_TAB])
        Rails.logger.warn("Ignoring item_tab because invalid tab name '#{v}'.")
      end
    end

    return self
  end

  def item_tab
    return self[Preference::ITEM_TAB]
  end

  def recent=(v)
    if (true == matching_type?(Preference::RECENT, v))
      if (true == v.is_a?(Array))
        remove_elements = v.size - Preference::MAX_RECENT

        if (0 < remove_elements)
          v = v.drop(remove_elements)
        end
      end

      @preferences[Preference::RECENT] = v
    end

    return self
  end

  def recent
    return self[Preference::RECENT]
  end

  def preferredTab?(name)
    if (true == name.is_a?(Symbol))
      name = "#{name}"
    end

    if (false == name.is_a?(String))
      raise "!ERROR: name is not a string. Type: '#{name.class}'. Value: '#{name}'."
    end

    return (self.item_tab == name)
  end

  def self.load(string_value)
    return Preference.new(string_value)
  end

  def self.dump(preference_object)
    return preference_object.to_json
  end

  private
  def matching_type?(k,v)
    current_v = @preferences[k]

    if (false == v.is_a?(current_v.class))
      Rails.logger.warn("Ignoring preference '#{k}' '#{current_v.class}' because class doesn't match '#{v.class}':'#{v}'.")
      return false
    end

    return true
  end
end
