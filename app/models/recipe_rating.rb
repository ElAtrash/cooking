# frozen_string_literal: true

class RecipeRating < ApplicationRecord
  belongs_to :recipe, counter_cache: true
  belongs_to :user

  validates :rating, presence: true, numericality: { in: 1..5 }
  validates :comment, length: { maximum: 500 }, allow_blank: true
  validates :user_id, uniqueness: { scope: :recipe_id, message: "has already been taken" }

  after_commit :update_recipe_average_rating

  scope :with_min_rating, ->(min_rating) { where("rating >= ?", min_rating) if min_rating.present? }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_rating, -> { order(rating: :desc) }

  def stars_display
    filled_stars = "★" * rating
    empty_stars = "☆" * (5 - rating)
    filled_stars + empty_stars
  end

  def has_comment?
    comment.present?
  end

  def short_comment(limit = 100)
    return "" unless has_comment?
    return comment if comment.length <= limit

    "#{comment.truncate(limit)}..."
  end

  def rating_color
    case rating
    when 1..2 then "red"
    when 3 then "yellow"
    when 4..5 then "green"
    end
  end

  def rating_badge_class
    case rating
    when 1..2 then "bg-red-100 text-red-800"
    when 3 then "bg-yellow-100 text-yellow-800"
    when 4..5 then "bg-green-100 text-green-800"
    end
  end

  private

  def update_recipe_average_rating
    recipe.update_average_rating if recipe
  end
end
