# frozen_string_literal: true

class Ingredient < ApplicationRecord
  has_many :recipe_ingredients, dependent: :destroy
  has_many :recipes, through: :recipe_ingredients

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }
  validates :category, presence: true, inclusion: {
    in: %w[produce dairy meat seafood grains spices pantry other]
  }

  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :search, ->(term) { where("name ILIKE ?", "%#{term}%") if term.present? }
  scope :alphabetical, -> { order(:name) }

  def display_name
    name.capitalize
  end

  def category_color
    case category
    when "produce" then "green"
    when "dairy" then "blue"
    when "meat" then "red"
    when "seafood" then "cyan"
    when "grains" then "yellow"
    when "spices" then "purple"
    when "pantry" then "gray"
    else "gray"
    end
  end

  def category_badge_class
    case category
    when "produce" then "bg-green-100 text-green-800"
    when "dairy" then "bg-blue-100 text-blue-800"
    when "meat" then "bg-red-100 text-red-800"
    when "seafood" then "bg-cyan-100 text-cyan-800"
    when "grains" then "bg-yellow-100 text-yellow-800"
    when "spices" then "bg-purple-100 text-purple-800"
    when "pantry" then "bg-gray-100 text-gray-800"
    else "bg-gray-100 text-gray-800"
    end
  end

  private

  def downcase_name
    self.name = name.downcase if name.present?
  end
end
