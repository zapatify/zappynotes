class UserMailer < ApplicationMailer
  default from: "noreply@zappynotes.com"

  def confirmation_email(user)
    @user = user
    @confirmation_url = confirm_email_url(token: @user.confirmation_token)

    mail(
      to: @user.email_address,
      subject: "Confirm your ZappyNotes account"
    )
  end
end
