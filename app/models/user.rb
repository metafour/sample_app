class User < ActiveRecord::Base
  before_save { email.downcase! }
  validates :name, presence: true, length: 3..50 # { maximum: 50, minimum: 3 }
  # Allows foo@bar..com
  #VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: { case_sensitive: false },
             format: { with: VALID_EMAIL_REGEX }
  validates :password, length: { minimum: 6 }
  has_secure_password
end
