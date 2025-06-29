class CreateRecipeSteps < ActiveRecord::Migration[8.0]
  def change
    create_table :recipe_steps do |t|
      t.references :recipe, null: false, foreign_key: true
      t.integer :step_number, null: false
      t.text :instruction, null: false, limit: 1000

      t.timestamps
    end

    add_index :recipe_steps, [ :recipe_id, :step_number ], unique: true
    add_index :recipe_steps, :step_number
  end
end
