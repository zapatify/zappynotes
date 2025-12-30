require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "confirmation_email" do
    let(:user) { create(:user) }
    let(:mail) { UserMailer.confirmation_email(user) }

    it "renders the headers" do
      expect(mail.subject).to eq("Confirm your ZappyNotes account")
      expect(mail.to).to eq([user.email_address])
      expect(mail.from).to eq(["noreply@zappynotes.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("Welcome to ZappyNotes")
      expect(mail.body.encoded).to include("Confirm My Email")
      expect(mail.body.encoded).to include(user.confirmation_token)
    end

    it "includes confirmation link" do
      expect(mail.body.encoded).to include("confirm_email")
      expect(mail.body.encoded).to include(user.confirmation_token)
    end
  end
end