FactoryBot.define do
  factory :notebook do
    user { nil }
    name { "MyString" }
    color { "MyString" }
    position { 1 }
  end
end
