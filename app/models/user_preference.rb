class UserPreference
  def self.items_tab(session)
    if ((nil != session) && (nil != session[:preferences]) && (nil != session[:preferences][:items_tab]))
      return session[:preferences][:items_tab]
    else
      return "all"
    end
  end
end
