require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:bbobberson)
  end

  test "username isn't blank" do
    @user.username = ""
    @user.save
    assert(@user.errors.messages.include?(:username))
    assert_equal("can't be blank", @user.errors.messages[:username].first)
  end

  test "name isn't blank" do
    @user.name = ""
    @user.save
    assert(@user.errors.messages.include?(:name))
    assert_equal("can't be blank", @user.errors.messages[:name].first)
  end

  test "password isn't blank on create" do
    user1 = @user.dup
    user1.password = ""
    @user.password = ""
    @user.save
    user1.save
    assert(@user.errors.messages.empty?)
    assert(user1.errors.messages.include?(:password))
    assert_equal("can't be blank", user1.errors.messages[:password].first)
  end

  test "username is at least six characters" do
    @user.username = "a"
    @user.save
    assert(@user.errors.messages.include?(:username))
    assert_equal(1, @user.errors.messages[:username].length)
    assert_equal("is too short (minimum is 6 characters)", @user.errors.messages[:username].first)
  end

  test "username is less than 60 characters" do
    @user.username = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    @user.save
    assert(@user.errors.messages.include?(:username))
    assert_equal(1, @user.errors.messages[:username].length)
    assert_equal("is too long (maximum is 60 characters)", @user.errors.messages[:username].first)
  end

  test "username is unique" do
    user1 = @user.dup
    user1.save
    assert(user1.errors.messages.include?(:username))
    assert_equal(1, user1.errors.messages[:username].length)
    assert_equal("has already been taken", user1.errors.messages[:username].first)
  end

  test "name is at least six characters" do
    @user.name = "a"
    @user.save
    assert(@user.errors.messages.include?(:name))
    assert_equal(1, @user.errors.messages[:name].length)
    assert_equal("is too short (minimum is 3 characters)", @user.errors.messages[:name].first)
  end

  test "name is less than 60 characters" do
    @user.name = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    @user.save
    assert(@user.errors.messages.include?(:name))
    assert_equal(1, @user.errors.messages[:name].length)
    assert_equal("is too long (maximum is 60 characters)", @user.errors.messages[:name].first)
  end

  test "password is at least six characters on create" do
    user1 = @user.dup
    user1.password = "a"
    @user.password = "a"
    user1.save
    @user.save
    assert(@user.errors.messages.empty?)
    assert(user1.errors.messages.include?(:password))
    assert_equal(1, user1.errors.messages[:password].length)
    assert_equal("is too short (minimum is 6 characters)", user1.errors.messages[:password].first)
  end

  test "password is less than 20 characters on create" do
    user1 = @user.dup
    user1.password = "aaaaaaaaaaaaaaaaaaaaa"
    @user.password = "aaaaaaaaaaaaaaaaaaaaa"
    user1.save
    @user.save
    assert(@user.errors.messages.empty?)
    assert(user1.errors.messages.include?(:password))
    assert_equal(1, user1.errors.messages[:password].length)
    assert_equal("is too long (maximum is 20 characters)", user1.errors.messages[:password].first)
  end

  test "setting password changes salt and results in new hashed_password" do
    salt  = @user.salt
    hpass = @user.hashed_password
    @user.password = "xxxxx"
    assert_not_equal(salt, @user.salt)
    assert_not_equal(hpass, @user.hashed_password)
    assert_equal(User.encrypted_password("xxxxx", @user.salt), @user.hashed_password)
  end

  test "salt exists" do
    @user.salt = ""
    @user.save
    assert(@user.errors.messages.include?(:salt))
    assert_equal(1, @user.errors.messages[:salt].length)
    assert_equal("can't be blank", @user.errors.messages[:salt].first)
  end

  test "hashed password exists" do
    @user.hashed_password = ""
    @user.save
    assert(@user.errors.messages.include?(:hashed_password))
    assert_equal(1, @user.errors.messages[:hashed_password].length)
    assert_equal("can't be blank", @user.errors.messages[:hashed_password].first)
  end

  test "serializing preferences works" do
    @user.preferences.item_tab = 'activities'
    @user.preferences.recent = [4,5,6]
    @user.save!
    @user.reload
    assert_equal([4,5,6], @user.preferences.recent)
    assert_equal('activities', @user.preferences.item_tab)
  end

  test "saving preferences with equals works" do
    @user.preferences = {'item_tab' => 'foods', 'dasdfasdf' => 'floff'}
    @user.save!
    assert(@user.errors.empty?)
    assert_equal('foods', @user.preferences.item_tab)
  end

  test "assigning preferences with new works" do
    user1 = User.new({:username => '123456', :password => '123456', :name => '123', :preferences => {'item_tab' => 'foods'}})
    user1.save!
    assert(user1.errors.empty?)
    assert_equal('foods', user1.preferences.item_tab)
  end

  test "assigning preferences by adding to the object works" do
    @user.preferences.item_tab = 'activities'
    @user.save!
    assert(@user.errors.empty?)
    assert_equal('activities', @user.preferences.item_tab)
  end

  test "assigning no preferences gives defaults" do
    user1 = User.new({:username => '123456', :password => '123456', :name => '123'})
    user1.save!
    assert(user1.errors.empty?)

    Preference::DEFAULTS.each do |k,v|
      if (true == v.is_a?(Symbol))
        v = "#{v}"
      end

      assert_equal(v, user1.preferences[k])
    end
  end

  test "back to back saves with preferences works" do
    @user.preferences['item_tab'] = 'other'
    @user.save
    assert(@user.errors.empty?)
    assert_equal('other', @user.preferences.item_tab)
    @user.preferences['item_tab'] = 'foods'
    @user.save
    assert(@user.errors.empty?)
    assert_equal('foods', @user.preferences.item_tab)
  end

  test "user can load their activities" do
    assert_equal(6, @user.activities.length)
  end

  test "user can register and authenticate" do 
    registered_user = User.register('testperson', 'testpassword', 'realname')
    assert_equal('testperson', registered_user.username)
    assert_equal('realname', registered_user.name)

    user_authenticate = User.authenticate('testperson', 'testpassword')
    assert_equal(registered_user.id, user_authenticate.id)
  end

  test "bad authenticate returns nil" do 
    [nil, "", "baduser"].each do |uname|
      user = User.authenticate(uname, 'password')
      assert_nil(user)
    end
  end

  test "username is case insensitive, password is case sensitive" do 
    registered_user = User.register('testperson', 'testpassword', 'realname')
    user = User.authenticate('TESTpERsON', 'testpassword')
    assert_equal(registered_user.id, user.id)
    user = User.authenticate('testperson', 'testPassword')
    assert_nil(user)
  end

  test "bad password or bad username returns nil" do 
    registered_user = User.register('testperson', 'testpassword', 'realname')

    user = User.authenticate('estperson', 'testpassword')
    assert_nil(user)

    user = User.authenticate('testperson', 'tstpassword')
    assert_nil(user)

    user = User.authenticate('testperson', registered_user.hashed_password)
    assert_nil(user)
  end

  test "age is nil if no birthday" do
    assert_nil(@user.age)
  end

  test "age is correct" do
    expected_age  = 25
    birthday = Date.today.change(:year => (Date.today.year - expected_age))
    @user.birthday = birthday

    assert_equal(expected_age, @user.age)
    @user.birthday = birthday.yesterday
    assert_equal(expected_age, @user.age)
    @user.birthday = birthday.tomorrow
    assert_equal(expected_age - 1, @user.age)
  end

  test "complete identifies when all settings are entered" do
    assert_not(@user.complete?)
    @user.gender = :male
    assert_not(@user.complete?)
    @user.birthday = "2000-01-01"
    assert_not(@user.complete?)
    @user.height = 100
    assert(@user.complete?)
    @user.height = nil
    @user.preferences.ignore_incomplete_settings = true
    assert_not(@user.complete?)
  end

  test "complete_or_ignore identifies when all settings are entered or we are ignoring whether settings are entered" do
    assert_not(@user.complete_or_ignore?)
    @user.gender = :male
    assert_not(@user.complete_or_ignore?)
    @user.birthday = "2000-01-01"
    assert_not(@user.complete_or_ignore?)
    @user.height = 100
    assert(@user.complete?)
    assert(@user.complete_or_ignore?)
    @user.height = nil
    @user.preferences.ignore_incomplete_settings = true
    assert_not(@user.complete?)
    assert(@user.complete_or_ignore?)
  end
end
