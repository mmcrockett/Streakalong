Rails.application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  root 'activities#index'
  match 'welcome',  :to => 'users#welcome', :via => [:get]
  match 'users',    :to => 'users#create',  :via => [:post]
  match 'users',    :to => 'users#login',   :via => [:get]
  match 'settings', :to => 'users#settings', :via => [:get]
  match 'settings', :to => 'users#update', :via => [:post]
  match 'logout',   :to => 'users#logout',  :via => [:get]
  match 'items',    :to => 'items#index', :via => [:get]
  match 'preferences', :to => 'preferences#index', :via => [:get]
  match 'preferences', :to => 'preferences#create', :via => [:post]
  match 'activities', :to => 'activities#index', :via => [:get]
  match 'calories',   :to => 'activities#calories', :via => [:get]
  match 'activities', :to => 'activities#create', :via => [:post]
end
