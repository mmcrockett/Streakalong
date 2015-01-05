Streakalong::Application.routes.draw do
  root :to => redirect('/calendar')
  resources :user_items
  match 'calendar', :to => 'user_items#calendar', :via => [:get]
  match 'streaks',  :to => 'user_items#streaks', :via => [:get]
  match 'welcome',  :to => 'users#welcome',  :via => [:get]
  match 'register', :to => 'users#register', :via => [:post]
  match 'login',    :to => 'users#login',    :via => [:post]
  match 'preference', :to => 'users#set_preference', :via => [:put]
  match 'preference', :to => 'users#get_preference', :via => [:get]
  match 'logout',   :to => 'users#logout',   :via => [:get]
  match 'key',      :to => 'users#key',      :via => [:get]
end
