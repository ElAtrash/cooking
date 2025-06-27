class CreateRecipes < ActiveRecord::Migration[8.0]
  def change
    create_table :recipes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false, limit: 100
      t.text :description, null: false, limit: 500
      t.integer :prep_time, null: false
      t.integer :cook_time, null: false
      t.integer :servings, null: false
      t.string :difficulty_level, null: false

      t.timestamps
    end

    add_index :recipes, :title
    add_index :recipes, :difficulty_level
    add_index :recipes, :created_at
    add_index :recipes, [ :prep_time, :cook_time ], name: 'index_recipes_on_total_time'
  end
end
