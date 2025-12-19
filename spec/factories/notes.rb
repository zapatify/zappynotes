FactoryBot.define do
  factory :note do
    notebook { nil }
    title { "MyString" }
    content { "MyText" }
    content_size { 1 }
    position { 1 }
  end
end
