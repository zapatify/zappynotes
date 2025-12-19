FactoryBot.define do
  factory :subscription do
    user { nil }
    stripe_subscription_id { "MyString" }
    stripe_customer_id { "MyString" }
    plan { "MyString" }
    status { "MyString" }
    current_period_end { "2025-12-17 23:07:37" }
  end
end
