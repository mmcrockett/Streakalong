class User < ActiveRecord::Base
  has_many :activities
  serialize :preferences, Preference
  before_save :initialize_preferences
  before_save :downcase_username
  validates :username, :presence => true
  validates :username, :length => { :minimum => 6, :maximum => 60 }
  validates :username, :uniqueness => true
  validates :name, :presence => true
  validates :name, :length => { :minimum => 3, :maximum => 60 }
  validates :password, :presence => true, :on => :create
  validates :password, :length => { :minimum => 6, :maximum => 20 }, :on => :create
  validates :salt, :presence => true
  validates :hashed_password, :presence => true

  def self.register(username, password, name)
    user = User.new()
    user.name     = name
    user.username = username
    user.password = password

    if (true == user.valid?)
      user.save()
    end

    return user
  end

  def self.authenticate(username, password)
    user = nil

    if ((nil != username) && (false == username.blank?))
      user = self.find_by_username(username.downcase)

      if (true == user.is_a?(User))
        stored_password = encrypted_password(password,user.salt)
        if (user.hashed_password != stored_password)
          user = nil
        end
      end
    end

    return user
  end

  def password=(pwd)
    @password = pwd
    process_password
  end

  def age
    age = nil

    if (true == self.birthday.is_a?(Date))
      age = Date.today.year - self.birthday.year
      if (Date.today < (birthday + age.years))
        age -= 1
      end
    end

    return age
  end

  def complete_or_ignore?
    return ((true == self.complete?) || (true == self.preferences.ignore_incomplete_settings))
  end

  def complete?
    return ((nil != self.birthday) && (nil != self.height) && (nil != self.gender))
  end

private
  def self.encrypted_password(password, salt)
    if (false == password.is_a?(String))
      raise "!ERROR: password is not a string '#{password.class}'."
    elsif (false == salt.is_a?(String))
      raise "!ERROR: salt is not a string '#{salt.class}'."
    end

    string_to_hashed = password + salt          
    Digest::SHA1.hexdigest(string_to_hashed)
  end
  
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

  def initialize_preferences
    if (false == self.preferences.is_a?(Preference))
      self.preferences = Preference.new({})
    end
  end

  def password
    return @password
  end

  def downcase_username
    self.username.downcase!
  end

  def process_password
    create_new_salt
    self.hashed_password = User.encrypted_password(@password, self.salt)
  end
end
