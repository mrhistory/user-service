require 'mongoid'

class User
  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessor :password, :password_confirmation

  field :organizations, type: Array
  field :email, type: String
  field :password_hash, type: String
  field :password_salt, type: String
  field :members, type: Array
  field :permissions, type: Array
  field :reset_token, type: String
  field :activation_token, type: String
  field :logged_in, type: Boolean

  before_save :prepare_password
  
  validates_presence_of :email
  validates_presence_of :organizations
  validates_uniqueness_of :email
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
  validate :check_password

  def check_password
    if self.new_record?
      errors.add(:base, "Password can't be blank") if self.password.blank?
      errors.add(:base, "Password and confirmation does not match") unless self.password == self.password_confirmation
      errors.add(:base, "Password must be at least 4 chars long") if self.password.to_s.size.to_i < 4
    else
      if self.password.blank?
        errors.add(:base, "Password can't be blank") if self.password.blank?
      else
        errors.add(:base, "Password and confirmation does not match") unless self.password == self.password_confirmation
        errors.add(:base, "Password must be at least 4 chars long") if self.password.to_s.size.to_i < 4
      end
    end
  end

  def self.authenticate(login, pass)
    user = first(:conditions => {:email => login})
    return user if user && user.matching_password?(pass)
  end

  def matching_password?(pass)
    self.password_hash == encrypt_password(pass)
  end


  private

  def prepare_password
    unless password.blank?
      self.password_salt = Digest::SHA1.hexdigest([Time.now, rand].join)
      self.password_hash = encrypt_password(password)
    end
  end
  
  def encrypt_password(pass)
    Digest::SHA1.hexdigest([pass, password_salt].join)
  end
end