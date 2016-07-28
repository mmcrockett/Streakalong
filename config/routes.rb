Rails.application.routes.draw do
  root 'activities#index'
  match 'welcome',  :to => 'users#welcome', :via => [:get]
  match 'users',    :to => 'users#create',  :via => [:post]
  match 'users',    :to => 'users#login',   :via => [:get]
  match 'logout',   :to => 'users#logout',  :via => [:get]
  match 'preferences', :to => 'preferences#index', :via => [:get]
  match 'preferences', :to => 'preferences#create', :via => [:post]
  match 'activities', :to => 'activities#index', :via => [:get]
  match 'activities', :to => 'activities#create', :via => [:post]
end
