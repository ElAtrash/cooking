class AddCounterCaches < ActiveRecord::Migration[8.0]
  def change
    add_column :recipes, :recipe_ratings_count, :integer, default: 0, null: false
    add_index :recipes, :recipe_ratings_count

    add_column :recipes, :favorite_recipes_count, :integer, default: 0, null: false
    add_index :recipes, :favorite_recipes_count

    add_column :users, :recipes_count, :integer, default: 0, null: false
    add_index :users, :recipes_count
  end
end
