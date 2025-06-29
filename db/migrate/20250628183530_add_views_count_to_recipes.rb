class AddViewsCountToRecipes < ActiveRecord::Migration[8.0]
  def change
   add_column :recipes, :views_count, :integer, default: 0, null: false
    add_index :recipes, :views_count
  end
end
