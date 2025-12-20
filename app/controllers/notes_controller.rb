class NotesController < ApplicationController
  before_action :require_authentication
  before_action :set_note, only: [ :show, :update, :destroy ]

  def show
    render json: {
      id: @note.id,
      title: @note.title,
      content: @note.content,
      rendered_content: @note.rendered_content,
      notebook_id: @note.notebook_id
    }
  end

  def create
    @notebook = current_user.notebooks.find(params[:notebook_id])

    unless current_user.can_create_note?(@notebook)
      render json: {
        error: "You've reached your note limit for this notebook. Please upgrade your plan.",
        upgrade_needed: true
      }, status: :unprocessable_entity
      return
    end

    @note = @notebook.notes.build(note_params)
    @note.position = @notebook.notes.count
    @note.content ||= "Start writing..."

    if @note.save
      render json: {
        id: @note.id,
        title: @note.title,
        content: @note.content,
        notebook_id: @note.notebook_id
      }, status: :created
    else
      render json: { errors: @note.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    additional_bytes = note_params[:content] ? note_params[:content].bytesize - @note.content_size : 0

    if additional_bytes > 0 && !current_user.can_add_content?(additional_bytes)
      render json: {
        error: "You've reached your storage limit. Please upgrade your plan.",
        upgrade_needed: true
      }, status: :unprocessable_entity
      return
    end

    if @note.update(note_params)
      render json: {
        id: @note.id,
        title: @note.title,
        content: @note.content,
        rendered_content: @note.rendered_content,
        saved_at: @note.updated_at.iso8601
      }
    else
      render json: { errors: @note.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @note.destroy
    head :no_content
  end

  private

  def set_note
    @note = current_user.notes.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:title, :content)
  end
end
