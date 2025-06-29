# frozen_string_literal: true

class FavoriteRecipe < ApplicationRecord
  belongs_to :recipe, counter_cache: true
  belongs_to :user

  validates :user_id, uniqueness: { scope: :recipe_id, message: "has already been taken" }

  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user: user) if user.present? }

  def self.toggle_for(user, recipe)
    return nil unless user && recipe

    existing_favorite = find_by(user: user, recipe: recipe)

    if existing_favorite
      existing_favorite.destroy
      nil
    else
      create(user: user, recipe: recipe)
    end
  end

  def self.favorited_by?(user, recipe)
    return false unless user && recipe

    exists?(user: user, recipe: recipe)
  end
end
