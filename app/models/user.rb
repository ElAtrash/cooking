class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :recipes, dependent: :destroy
  has_many :recipe_ratings, dependent: :destroy
  has_many :favorite_recipes, dependent: :destroy

  validates :email_address, presence: true, uniqueness: { case_sensitive: false }
  validates :password, presence: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
