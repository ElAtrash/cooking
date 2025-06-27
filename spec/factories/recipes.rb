# frozen_string_literal: true

FactoryBot.define do
  factory :recipe do
    association :user
    title { Faker::Food.dish }
    description { Faker::Food.description }
    prep_time { rand(5..30) }
    cook_time { rand(10..120) }
    servings { rand(1..8) }
    difficulty_level { %w[easy medium hard].sample }

    trait :with_image do
      after(:build) do |recipe|
        recipe.image.attach(
          io: FIle.open(Rails.root.join('spec', 'fixtures', 'files', 'recipe_image.jpg')),
          filename: 'recipe_image.jpg',
          content_type: 'image/jpeg'
        )
      end
    end

    trait :easy do
      difficulty_level { 'easy' }
      prep_time { rand(5..15) }
      cook_time { rand(10..30) }
    end

    trait :quick do
      prep_time { rand(5..10) }
      cook_time { rand(10..20) }
    end

    trait :with_raitings do
      after(:create) do |recipe|
        3.times do
          create(:recipe_rating, recipe: recipe, rating: rand(3..5))
        end
      end
    end

    trait :with_ingredients do
      after(:create) do |recipe|
        3.times do
          ingredient = create(:ingredient)
          create(:recipe_ingredient, recipe: recipe, ingredient: ingredient)
        end
      end
    end

    trait :with_steps do
      after(:create) do |recipe|
        5.times do |i|
          create(:recipe_step, recipe: recipe, step_number: i + 1)
        end
      end
    end

    trait :complete do
      with_ingredients
      with_steps
      with_raitings
    end
  end
end
