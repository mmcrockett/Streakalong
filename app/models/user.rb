require 'digest/sha1'
require 'openssl'

class User < ActiveRecord::Base
  has_many :user_items
  serialize :preferences, JSON
  before_create :set_preferences_default
  validates :username, :presence => true
  validates :username, :length => { :minimum => 6, :maximum => 60 }
  validates :username, :uniqueness => true
  validates :name, :presence => true
  validates :name, :length => { :minimum => 3, :maximum => 60 }
  validates :password, :presence => true
  validates :password, :length => { :minimum => 6, :maximum => 20 }
  validates :hashed_password, :presence => true

  def self.public_key
    if (true == Rails.env.production?)
      return File.read("streakalong.public.production.pem")
    else
      return File.read("streakalong.public.development.pem")
    end
  end

  def self.private_key
    if (true == Rails.env.production?)
      return File.read("streakalong.private.production.pem")
    else
      return File.read("streakalong.private.development.pem")
    end
  end

  def self.decrypt_rsa(password_rsa_encrypted)
    rsa = OpenSSL::PKey::RSA.new(self.private_key)

    return rsa.private_decrypt(Base64.decode64(password_rsa_encrypted))
  end
  
  def self.register(username, password_rsa_encrypted, name)
    user = User.new()
    user.name     = name
    user.username = username
    user.password = self.decrypt_rsa(password_rsa_encrypted)

    if (true == user.valid?)
      user.save()
    end

    return user
  end

  def self.authenticate(username, password_rsa_encrypted)
    user = nil

    if ((nil != username) && (false == username.blank?))
      password = self.decrypt_rsa(password_rsa_encrypted)
      user = self.find_by_username(username.downcase)

      if user
        stored_password = encrypted_password(password,user.salt)
        if user.hashed_password != stored_password
          user = nil
        end
      end
    end

    return user
  end
  
  # 'password' is a virtual attribute
  def password
    @password
  end
  
  def password=(pwd)
    @password = pwd
    create_new_salt
    self.hashed_password = User.encrypted_password(self.password, self.salt)
  end

  def item_tab
    return self.preferences[UserPreference::ITEM_TAB]
  end

  def recent_items
    return self.preferences[UserPreference::RECENT]
  end

  def categorized_items
    return [{:all => Item::ALL},{:recent => self.recent_items},{:foods  => Item::FOODS},{:beverages  => Item::BEVERAGES},{:activities => Item::ACTIVITIES},{:other => Item::OTHER}]
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
  
private
  def self.encrypted_password(password, salt)
    string_to_hashed = password + salt          
    Digest::SHA1.hexdigest(string_to_hashed)
  end
  
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

  def set_preferences_default
    self.preferences = UserPreference::DEFAULTS
  end
end
