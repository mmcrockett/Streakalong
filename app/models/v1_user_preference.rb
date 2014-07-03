class V1UserPreference < ActiveRecord::Base
  belongs_to :user

  MAX_RECENT_STREAKS = 10

  RECENT           = 'recent'
  RECENT_DISPLAYED = 'recent_displayed'
  TAB              = 'tab'
  HEALTHSCORE      = 'healthscore'
  CALENDAR         = 'calendar'
  STREAK_DISPLAY   = {:name => 'streak_display', :collapsed => 'c', :expanded => 'e'}
  STREAK_HIDDEN_GRAPHS = 'streak_hidden_graphs'

  PREF_DEFAULT     = {
                      RECENT => '',
                      RECENT_DISPLAYED => '',
                      TAB => 1,
                      HEALTHSCORE => 1,
                      CALENDAR => Calendar::DAY_TYPE,
                      STREAK_DISPLAY[:name] => STREAK_DISPLAY[:expanded],
                      STREAK_HIDDEN_GRAPHS => ''
                     }

  def self.create_user_preferences(session)
    uid = session[:user_id]

    PREF_DEFAULT.each_pair do |key, default|
      if (nil == UserPreference.find_by_user_id_and_name(uid, key))
        UserPreference.create(:user_id => uid, :name => key, :value => default)
      end
    end

    self.update_user_preferences(session)
  end

  def self.update_user_preferences(session)
    session[:userprefs][UserPreference::TAB]                   = Integer(UserPreference.find_by_user_id_and_name(session[:user_id], UserPreference::TAB).value)
    session[:userprefs][UserPreference::HEALTHSCORE]           = Integer(UserPreference.find_by_user_id_and_name(session[:user_id], UserPreference::HEALTHSCORE).value)
    session[:userprefs][UserPreference::RECENT]                = Array(UserPreference.find_by_user_id_and_name(session[:user_id], UserPreference::RECENT).value.split(","))
    session[:userprefs][UserPreference::CALENDAR]              = String(UserPreference.find_by_user_id_and_name(session[:user_id], UserPreference::CALENDAR).value)
    session[:userprefs][UserPreference::RECENT_DISPLAYED]      = Array(UserPreference.find_by_user_id_and_name(session[:user_id], UserPreference::RECENT_DISPLAYED).value.split(","))
    session[:userprefs][UserPreference::STREAK_DISPLAY[:name]] = UserPreference.find_by_user_id_and_name(session[:user_id], UserPreference::STREAK_DISPLAY[:name]).value
    session[:userprefs][UserPreference::STREAK_HIDDEN_GRAPHS]  = Array(UserPreference.find_by_user_id_and_name(session[:user_id], UserPreference::STREAK_HIDDEN_GRAPHS).value.split(","))

    session[:last_update] = Time.now().to_i()
  end

  def self.set(session, name, value)
    if (true == session[:userprefs].has_key?(name))
      begin
        session[:userprefs][name] = Integer(value)
      rescue
        session[:userprefs][name] = value
      end
    end

    pref = UserPreference.find_by_user_id_and_name(session[:user_id], name)

    if (nil != pref)
      pref.value = value
      pref.save()
    end
  end

  def self.add_recent_displayed(user_id, item_id)
    return UserPreference.add(user_id, item_id, RECENT_DISPLAYED, MAX_RECENT_STREAKS)
  end

  def self.remove_recent_displayed(user_id, item_id)
    return UserPreference.remove(user_id, item_id, RECENT_DISPLAYED)
  end

  def self.add_streak_hidden_graph(user_id, item_id)
    return UserPreference.add(user_id, item_id, STREAK_HIDDEN_GRAPHS)
  end

  def self.remove_streak_hidden_graph(user_id, item_id)
    return UserPreference.remove(user_id, item_id, STREAK_HIDDEN_GRAPHS)
  end

  def self.add_recent(user_id, item_id)
    return UserPreference.add(user_id, item_id, RECENT, Item::MAX_NAV_ITEMS)
  end

  def self.add(user_id, item_id, key, max = nil)
    recent_pref = UserPreference.find_by_user_id_and_name(user_id, key)
    item_id = String(item_id)

    recent = Array(recent_pref.value.split(","))

    recent.delete(item_id)

    recent << item_id

    while ((nil != max) and (max < recent.size) and (0 != max))
      recent.shift
    end

    recent_pref[:value] = recent.join(",")
    recent_pref.save()

    return recent
  end

  def self.remove(user_id, item_id, key)
    recent_pref = UserPreference.find_by_user_id_and_name(user_id, key)
    item_id = String(item_id)

    recent = Array(recent_pref.value.split(","))
    recent.delete(item_id)
    recent_pref[:value] = recent.join(",")
    recent_pref.save()

    return recent
  end

  def self.show_healthscore?(session)
    if (1 == session[:userprefs][UserPreference::HEALTHSCORE])
      return true
    else
      return false
    end
  end
end
