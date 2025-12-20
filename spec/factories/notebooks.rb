FactoryBot.define do
  factory :notebook do
    association :user
    sequence(:name) { |n| "Notebook #{n}" }
    color { "black" }
    position { 0 }

    trait :red do
      color { "red" }
    end

    trait :with_notes do
      after(:create) do |notebook|
        create_list(:note, 3, notebook: notebook)
      end
    end
  end
end
