# frozen_string_literal: true

class RecipeIngredient < ApplicationRecord
  belongs_to :recipe
  belongs_to :ingredient

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit, presence: true, length: { maximum: 20 }
  validates :notes, length: { maximum: 100 }, allow_blank: true
  validates :ingredient_id, uniqueness: { scope: :recipe_id, message: "has already been taken" }

  scope :by_quantity, -> { order(quantity: :desc) }

  def display_quantity
    quantity.to_i == quantity ? quantity.to_i : quantity
  end

  def full_description
    description = "#{display_quantity} #{unit} #{ingredient.name}"
    description += " (#{notes})" if notes.present?
    description
  end

  def unit_plural?
    quantity > 1
  end

  def formatted_unit
    return unit if unit_plural? || unit.ends_with?("s")

    case unit
    when "cup" then quantity > 1 ? "cups" : "cup"
    when "piece" then quantity > 1 ? "pieces" : "piece"
    when "clove" then quantity > 1 ? "cloves" : "clove"
    else unit
    end
  end
end
