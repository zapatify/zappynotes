class SubscriptionsController < ApplicationController
  before_action :require_authentication

  def show
    @subscription = current_user.subscription
  end

  def create
    price_id = params[:price_id]

    session = Stripe::Checkout::Session.create(
      customer_email: current_user.email_address,
      mode: "subscription",
      line_items: [ {
        price: price_id,
        quantity: 1
      } ],
      success_url: checkout_success_subscription_url,
      cancel_url: root_url
    )

    render json: { url: session.url }
  rescue Stripe::StripeError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def checkout_success
    # Success page after Stripe checkout
    redirect_to app_root_path, notice: "Subscription successful! Your plan has been upgraded."
  end
end
