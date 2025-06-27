class CreateIngredients < ActiveRecord::Migration[8.0]
  def change
    create_table :ingredients do |t|
      t.string :name, null: false, limit: 50
      t.string :category, null: false

      t.timestamps
    end

    add_index :ingredients, :name, unique: true
    add_index :ingredients, :category
  end
end
