class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include Authentication

  private

  def require_authentication
    resume_session || redirect_to(sign_in_path, alert: "Please sign in to continue")
  end

  # Helper method for views
  helper_method :current_user

  def current_user
    Current.user
  end
end
