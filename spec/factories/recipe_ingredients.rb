# frozen_string_literal: true

FactoryBot.define do
  factory :recipe_ingredient do
    association :recipe
    association :ingredient
    quantity { rand(0.25..5.0).round(2) }
    unit { %w[cup cups tbsp tsp oz lb piece pieces clove cloves].sample }
    notes { [ nil, 'diced', 'chopped', 'minced', 'sliced', 'grated' ].sample }

    trait :main_ingredient do
      quantity { rand(1..3) }
      unit { %w[cup cups lb oz].sample }
    end

    trait :seasoning do
      quantity { rand(0.25..1.0).round(2) }
      unit { %w[tsp tbsp pinch].sample }
      association :ingredient, :spices
    end

    trait :produce do
      quantity { rand(1..2) }
      unit { %w[piece pieces cup cups].sample }
      association :ingredient, :produce
      notes { %w[diced chopped sliced].sample }
    end
  end
end
