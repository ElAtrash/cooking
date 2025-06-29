# frozen_string_literal: true

FactoryBot.define do
  factory :recipe_step do
    association :recipe
    sequence(:step_number) { |n| n }
    instruction { Faker::Food.description }

    trait :with_image do
      after(:build) do |step|
        image_data = "\xFF\xD8\xFF\xE0\x00\x10JFIF\x00\x01\x01\x01\x00H\x00H\x00\x00\xFF\xD9"
        step.image.attach(
          io: StringIO.new(image_data),
          filename: "step_image.jpg",
          content_type: "image/jpeg"
        )
      end
    end

    trait :prep_step do
      instruction { [ "Wash and chop vegetables", "Measure all ingredients", "Preheat oven to 350°C" ].sample }
    end

    trait :cooking_step do
      instruction { [ "Heat oil in pan", "Add ingredients and stir", "Cook for 10 minutes" ].sample }
    end

    trait :final_step do
      instruction { [ "Serve immediately", "Garnish and enjoy", "Let cool before serving" ].sample }
    end

    trait :long_instruction do
      instruction {
        "This is a very long instruction that contains detailed information about the cooking process, including specific temperatures, timing, and techniques that need to be followed carefully to achieve the best results."
      }
    end
  end
end
