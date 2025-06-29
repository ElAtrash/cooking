# frozen-string-literal: true

class Recipe < ApplicationRecord
  belongs_to :user, counter_cache: true
  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients
  has_many :recipe_steps, dependent: :destroy
  has_many :recipe_ratings, dependent: :destroy
  has_many :favorite_recipes, dependent: :destroy
  has_one_attached :image

  validates :title, presence: true, length: { maximum: 100 }
  validates :description, presence: true, length: { maximum: 500 }
  validates :prep_time, presence: true, numericality: { greater_than: 0 }
  validates :cook_time, presence: true, numericality: { greater_than: 0 }
  validates :servings, presence: true, numericality: { greater_than: 0 }
  validates :difficulty_level, presence: true, inclusion: { in: %w[easy medium hard] }

  scope :by_difficulty, ->(level) { where(difficulty_level: level) if level.present? }
  scope :quick, -> { where("prep_time + cook_time <= 30") }
  scope :recent, -> { order(created_at: :desc) }
  scope :search, ->(term) {
    where("title ILIKE ? OR description ILIKE ?", "%#{term}%", "%#{term}%") if term.present?
  }

  def total_time
    prep_time + cook_time
  end

  def average_rating
    return 0 if recipe_ratings.empty?

    recipe_ratings.average(:rating).round(1)
  end

  def favorited_by?(user)
    return false unless user

    favorite_recipes.exists?(user: user)
  end

  def difficulty_color
    case difficulty_level
    when "easy" then "green"
    when "medium" then "yellow"
    when "hard" then "red"
    end
  end

  def difficulty_badge_class
    case difficulty_level
    when "easy" then "bg-green-100 text-green-800"
    when "medium" then "bg-yellow-100 text-yellow-800"
    when "hard" then "bg-red-100 text-red-800"
    end
  end

  def update_average_rating
    # This could be used to cache the average rating in the future
    # For now, we calculate it on-demand in the average_rating method
  end
end
