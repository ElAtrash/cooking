Rails.application.eager_load!
ApplicationRecord.descendants.each { |model| model.delete_all }

# Create admin and regular user accounts
puts "Creating sample users..."

# Create admin user
admin = User.create!(
  email_address: "admin@example.com",
  password: "password123",
  password_confirmation: "password123"
)

# Create regular user
user = User.create!(
  email_address: "user@example.com",
  password: "password123",
  password_confirmation: "password123"
)

puts "Created admin user: #{admin.email_address}"
puts "Created regular user: #{user.email_address}"
puts "Default password for both: password123"

# Create sample ingredients
ingredients = [
  { name: "tomato", category: "produce" },
  { name: "onion", category: "produce" },
  { name: "garlic", category: "produce" },
  { name: "olive oil", category: "pantry" },
  { name: "salt", category: "spices" },
  { name: "black pepper", category: "spices" },
  { name: "basil", category: "spices" },
  { name: "mozzarella cheese", category: "dairy" },
  { name: "chicken breast", category: "meat" },
  { name: "pasta", category: "grains" }
]

created_ingredients = ingredients.map do |ing|
  Ingredient.create!(ing)
end

puts "Created #{created_ingredients.count} ingredients"

# Create sample recipes
recipes_data = [
  {
    title: "Spaghetti Carbonara",
    description: "A classic Italian pasta dish with eggs, cheese, and pancetta",
    prep_time: 15,
    cook_time: 20,
    servings: 4,
    difficulty_level: "medium"
  },
  {
    title: "Margherita Pizza",
    description: "Traditional Italian pizza with tomatoes, mozzarella, and basil",
    prep_time: 30,
    cook_time: 15,
    servings: 2,
    difficulty_level: "easy"
  },
  {
    title: "Chicken Parmesan",
    description: "Breaded chicken breast with marinara sauce and melted cheese",
    prep_time: 20,
    cook_time: 25,
    servings: 4,
    difficulty_level: "medium"
  }
]

recipes_data.each do |recipe_data|
  recipe = user.recipes.create!(recipe_data)
  # Add some random ingredients to each recipe
  created_ingredients.sample(3).each do |ingredient|
    recipe.recipe_ingredients.create!(
      ingredient: ingredient,
      quantity: rand(1..3),
      unit: [ "cup", "tbsp", "tsp", "piece" ].sample,
      notes: [ "diced", "chopped", "minced", nil ].sample
    )
  end

  # Add cooking steps
  steps = [
    "Prepare all ingredients and equipment",
    "Heat oil in a large pan over medium heat",
    "Cook until golden brown and tender",
    "Season with salt and pepper to taste",
    "Serve immediately while hot"
  ]

  steps.each_with_index do |instruction, index|
    recipe.recipe_steps.create!(
      step_number: index + 1,
      instruction: instruction
    )
  end

  puts "Created recipe: #{recipe.title}"
end

puts "Sample data created successfully!"
