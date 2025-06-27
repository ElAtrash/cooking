# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email_address { Faker::Internet.email }
    password { "password123" }
    password_confirmation { "password123" }

    trait :admin do
      email_address { "admin@example.com" }
    end

    trait :regular_user do
      email_address { "user@example.com" }
    end
  end
end
