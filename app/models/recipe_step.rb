# frozen_string_literal: true

class RecipeStep < ApplicationRecord
  belongs_to :recipe
  has_one_attached :image

  validates :step_number, presence: true, numericality: { greater_than: 0 }
  validates :instruction, presence: true, length: { maximum: 1000 }
  validates :step_number, uniqueness: { scope: :recipe_id, message: "has already been taken" }

  before_validation :set_step_number, if: -> { step_number.blank? && recipe.present? }

  scope :ordered, -> { order(:step_number) }

  def short_instruction(limit = 100)
    return instruction if instruction.length <= limit

    "#{instruction.truncate(limit)}..."
  end

  def has_image?
    image.attached?
  end

  def is_first_step?
    step_number == 1
  end

  def is_last_step?
    step_number == recipe.recipe_steps.maximum(:step_number)
  end

  def next_step
    recipe.recipe_steps.find_by(step_number: step_number + 1)
  end

  def previous_step
    recipe.recipe_steps.find_by(step_number: step_number - 1)
  end

  private

  def set_step_number
    max_step = recipe.recipe_steps.maximum(:step_number) || 0
    self.step_number = max_step + 1
  end
end
