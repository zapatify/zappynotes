FactoryBot.define do
  factory :subscription do
    association :user
    plan { :free }
    status { :active }
    stripe_subscription_id { "sub_#{SecureRandom.hex(12)}" }
    stripe_customer_id { "cus_#{SecureRandom.hex(12)}" }
    current_period_end { 1.month.from_now }

    trait :plus do
      plan { :plus }
    end

    trait :pro do
      plan { :pro }
    end

    trait :canceled do
      status { :canceled }
    end

    trait :past_due do
      status { :past_due }
    end
  end
end
