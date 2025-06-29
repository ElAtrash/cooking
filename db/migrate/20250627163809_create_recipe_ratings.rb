class CreateRecipeRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :recipe_ratings do |t|
      t.references :recipe, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text :comment, limit: 500

      t.timestamps
    end

    add_index :recipe_ratings, [ :recipe_id, :user_id ], unique: true
    add_index :recipe_ratings, :rating
    add_index :recipe_ratings, :created_at
  end
end
