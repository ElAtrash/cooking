# frozen_string_literal: true

FactoryBot.define do
  factory :ingredient do
    sequence(:name) { |n| "#{Faker::Food.ingredient.downcase}_#{n}" }
    category { %w[produce dairy meat seafood grains spices pantry other].sample }

    trait :produce do
      category { 'produce' }
      name { %w[tomato onion carrot potato lettuce spinach cucumber].sample }
    end

    trait :dairy do
      category { 'dairy' }
      name { %w[milk cheese butter yogurt cream].sample }
    end

    trait :meat do
      category { 'meat' }
      name { %w[chicken beef pork lamb turkey].sample }
    end

    trait :seafood do
      category { 'seafood' }
      name { %w[salmon tuna shrimp crab lobster].sample }
    end

    trait :spices do
      category { 'spices' }
      name { %w[salt pepper garlic basil oregano thyme].sample }
    end
  end
end
