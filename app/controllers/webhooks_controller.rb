class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :require_authentication

  def stripe
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = ENV["STRIPE_WEBHOOK_SECRET"]

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      render json: { error: "Invalid payload" }, status: :bad_request
      return
    rescue Stripe::SignatureVerificationError => e
      render json: { error: "Invalid signature" }, status: :bad_request
      return
    end

    case event.type
    when "checkout.session.completed"
      handle_checkout_completed(event.data.object)
    when "customer.subscription.updated"
      handle_subscription_updated(event.data.object)
    when "customer.subscription.deleted"
      handle_subscription_deleted(event.data.object)
    when "invoice.payment_failed"
      handle_payment_failed(event.data.object)
    end

    render json: { status: "success" }
  end

  private

  def handle_checkout_completed(session)
    user = User.find_by(email_address: session.customer_email)
    return unless user

    subscription_data = Stripe::Subscription.retrieve(session.subscription)
    plan = determine_plan(subscription_data.items.data[0].price.id)

    user.create_subscription!(
      stripe_subscription_id: subscription_data.id,
      stripe_customer_id: session.customer,
      plan: plan,
      status: subscription_data.status,
      current_period_end: Time.at(subscription_data.current_period_end)
    )
  end

  def handle_subscription_updated(subscription)
    sub = Subscription.find_by(stripe_subscription_id: subscription.id)
    return unless sub

    plan = determine_plan(subscription.items.data[0].price.id)
    sub.update(
      plan: plan,
      status: subscription.status,
      current_period_end: Time.at(subscription.current_period_end)
    )
  end

  def handle_subscription_deleted(subscription)
    sub = Subscription.find_by(stripe_subscription_id: subscription.id)
    return unless sub

    sub.update(status: "canceled", plan: "free")
  end

  def handle_payment_failed(invoice)
    sub = Subscription.find_by(stripe_subscription_id: invoice.subscription)
    return unless sub

    sub.update(status: "past_due")
  end

  def determine_plan(price_id)
    case price_id
    when ENV["STRIPE_PLUS_PRICE_ID"]
      "plus"
    when ENV["STRIPE_PRO_PRICE_ID"]
      "pro"
    else
      "free"
    end
  end
end
