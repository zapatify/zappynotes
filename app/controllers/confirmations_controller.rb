class ConfirmationsController < ApplicationController
  allow_unauthenticated_access

  def show
    user = User.find_by(confirmation_token: params[:token])

    if user.nil?
      redirect_to sign_in_path, alert: "Invalid confirmation link."
    elsif user.confirmed?
      redirect_to sign_in_path, notice: "Your email is already confirmed. Please sign in."
    elsif user.confirmation_token_expired?
      redirect_to sign_in_path, alert: "Confirmation link has expired. Please sign up again."
    else
      user.confirm!
      redirect_to sign_in_path, notice: "Email confirmed! You can now sign in."
    end
  end

  def resend
    user = User.find_by(email_address: params[:email_address])

    if user && !user.confirmed?
      user.send_confirmation_email
      redirect_to sign_in_path, notice: "Confirmation email resent. Please check your inbox."
    else
      redirect_to sign_in_path, alert: "Email not found or already confirmed."
    end
  end
end
