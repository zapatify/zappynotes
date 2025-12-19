Rails.application.config.to_prepare do
  Motor::ApplicationController.class_eval do
    before_action :require_admin!

    private

    def require_admin!
      # Get current session
      session_id = cookies.signed[:session_id]
      session_record = session_id ? Session.find_by(id: session_id) : nil
      
      if session_record
        Current.session = session_record
        user = session_record.user
        
        if user&.admin?
          # User is authenticated and is admin - allow access
          return
        else
          # User is authenticated but not admin
          redirect_to "/", alert: "Admin access required"
        end
      else
        # User is not authenticated
        redirect_to "/sign_in", alert: "Please sign in"
      end
    end
  end
end