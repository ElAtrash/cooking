# frozen_string_literal: true

FactoryBot.define do
  factory :favorite_recipe do
    association :recipe
    association :user

    trait :recent do
      created_at { rand(1.hour..1.day).seconds.ago }
    end

    trait :old do
      created_at { rand(1.week..1.month).seconds.ago }
    end
  end
end
