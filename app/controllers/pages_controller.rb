class PagesController < ApplicationController
  skip_before_action :require_authentication, only: [:landing]

  def landing
    # If user is already signed in, redirect to app
    if resume_session && Current.user
      redirect_to app_root_path
    end
    # Otherwise show landing page
  end
end

