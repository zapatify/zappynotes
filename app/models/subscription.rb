class Subscription < ApplicationRecord
  belongs_to :user

  validates :plan, presence: true, inclusion: { in: %w[free plus pro] }
  validates :status, presence: true

  enum :plan, { free: "free", plus: "plus", pro: "pro" }
  enum :status, {
    active: "active",
    canceled: "canceled",
    past_due: "past_due",
    incomplete: "incomplete",
    trialing: "trialing"
  }

  def active?
    status == "active" || status == "trialing"
  end
end
