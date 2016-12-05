class Admin < ActiveRecord::Base
  has_secure_password
  validates :password, presence: true, on: :create, length: {minimum: 6}
end
