FactoryBot.define do
  factory :note do
    association :notebook
    sequence(:title) { |n| "Note #{n}" }
    content { "# Sample Note\n\nThis is a test note with some **bold** text." }
    position { 0 }
  end
end
