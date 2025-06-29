# frozen_string_literal: true

FactoryBot.define do
  factory :recipe_rating do
    association :recipe
    association :user
    rating { rand(1..5) }
    comment { [ nil, Faker::Food.description, 'Great recipe!', 'Could be better', 'Amazing!' ].sample }

    trait :excellent do
      rating { 5 }
      comment { [ 'Amazing recipe!', 'Perfect!', 'Best dish ever!' ].sample }
    end

    trait :good do
      rating { 4 }
      comment { [ 'Really good', 'Would make again', 'Tasty!' ].sample }
    end

    trait :average do
      rating { 3 }
      comment { [ 'It was okay', 'Average recipe', 'Not bad' ].sample }
    end

    trait :poor do
      rating { [ 1, 2 ].sample }
      comment { [ 'Not great', 'Could be improved', 'Disappointing' ].sample }
    end

    trait :with_comment do
      comment { Faker::Lorem.paragraph(sentence_count: 2) }
    end

    trait :without_comment do
      comment { nil }
    end

    trait :recent do
      created_at { rand(1.hour..1.day).seconds.ago }
    end

    trait :old do
      created_at { rand(1.week..1.month).seconds.ago }
    end
  end
end
