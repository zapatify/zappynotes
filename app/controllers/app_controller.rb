class AppController < ApplicationController
  before_action :require_authentication

  def index
    @notebooks = current_user.notebooks.includes(:notes)
    
    # Find the note to display (from params or last edited)
    if params[:note_id]
      @selected_note = current_user.notes.find_by(id: params[:note_id])
    elsif current_user.notes.any?
      @selected_note = current_user.notes.order(updated_at: :desc).first
    end
  end
end