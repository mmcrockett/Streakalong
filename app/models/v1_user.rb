require 'digest/sha1'

class V1User < ActiveRecord::Base
  has_many :user_items
  has_many :user_preferences
  validates_presence_of   :username, :name
  validates_uniqueness_of :username
  
  attr_accessor   :password_confirmation
  validates_confirmation_of :password
  
  def validate
    errors.add_to_base("Missing Password") if hashed_password.blank?
  end
  
  def self.authenticate(username,password)
    user = self.find_by_username(username)
    if user
      stored_password = encrypted_password(password,user.salt)
      if user.hashed_password != stored_password
        user = nil
      end
    end
    user    # return user
  end
  
  # 'password' is a virtual attribute
  def password
    @password
  end
  
  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = V1User.encrypted_password(self.password, self.salt)
  end
  
  private
  
  def self.encrypted_password(password, salt)
    string_to_hashed = password + salt          
    Digest::SHA1.hexdigest(string_to_hashed)    #return SHA1 hash from the salted password
  end
  
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
end
