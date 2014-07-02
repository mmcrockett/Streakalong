class UserPreference
  ITEM_TAB = 'item_tab'
  RECENT   = 'recent'

  DEFAULTS = {
    ITEM_TAB => 'all',
    RECENT   => []
  }

  def self.items_tab(session)
    if (nil != @user)
      return @user.preferences[ITEM_TAB]
    else
      return "all"
    end
  end
end
