FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    first_name { "John" }
    last_name { "Doe" }
    admin { false }

    trait :admin do
      admin { true }
    end

    trait :with_subscription do
      after(:create) do |user|
        create(:subscription, user: user, plan: :plus)
      end
    end
  end
end
