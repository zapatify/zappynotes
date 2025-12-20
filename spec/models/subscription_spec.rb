require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:plan) }
    it { should validate_presence_of(:status) }
  end

  describe 'enums' do
    it 'defines plan enum' do
      expect(Subscription.plans.keys).to match_array(['free', 'plus', 'pro'])
    end

    it 'defines status enum' do
      expect(Subscription.statuses.keys).to match_array(['active', 'canceled', 'past_due', 'incomplete', 'trialing'])
    end
  end

  describe '#active?' do
    it 'returns true for active subscription' do
      subscription = create(:subscription, status: :active)
      expect(subscription.active?).to eq(true)
    end

    it 'returns true for trialing subscription' do
      subscription = create(:subscription, status: :trialing)
      expect(subscription.active?).to eq(true)
    end

    it 'returns false for canceled subscription' do
      subscription = create(:subscription, status: :canceled)
      expect(subscription.active?).to eq(false)
    end

    it 'returns false for past_due subscription' do
      subscription = create(:subscription, status: :past_due)
      expect(subscription.active?).to eq(false)
    end

    it 'returns false for incomplete subscription' do
      subscription = create(:subscription, status: :incomplete)
      expect(subscription.active?).to eq(false)
    end
  end

  describe 'plan management' do
    it 'can create free subscription' do
      subscription = create(:subscription, plan: :free)
      expect(subscription.plan).to eq('free')
    end

    it 'can create plus subscription' do
      subscription = create(:subscription, :plus)
      expect(subscription.plan).to eq('plus')
    end

    it 'can create pro subscription' do
      subscription = create(:subscription, :pro)
      expect(subscription.plan).to eq('pro')
    end
  end

  describe 'Stripe integration' do
    it 'stores Stripe subscription ID' do
      subscription = create(:subscription)
      expect(subscription.stripe_subscription_id).to be_present
      expect(subscription.stripe_subscription_id).to start_with('sub_')
    end

    it 'stores Stripe customer ID' do
      subscription = create(:subscription)
      expect(subscription.stripe_customer_id).to be_present
      expect(subscription.stripe_customer_id).to start_with('cus_')
    end

    it 'stores current period end date' do
      subscription = create(:subscription)
      expect(subscription.current_period_end).to be_present
      expect(subscription.current_period_end).to be > Time.current
    end
  end
end
