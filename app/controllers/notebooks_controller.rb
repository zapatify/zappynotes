class NotebooksController < ApplicationController
  before_action :require_authentication
  before_action :set_notebook, only: [ :update, :destroy, :update_color ]

  def create
    unless current_user.can_create_notebook?
      render json: {
        error: "You've reached your notebook limit. Please upgrade your plan to create more notebooks.",
        upgrade_needed: true
      }, status: :unprocessable_entity
      return
    end

    @notebook = current_user.notebooks.build(notebook_params)
    @notebook.position = current_user.notebooks.count
    @notebook.color ||= "black"

    if @notebook.save
      render json: {
        id: @notebook.id,
        name: @notebook.name,
        color: @notebook.color
      }, status: :created
    else
      render json: { errors: @notebook.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @notebook.update(notebook_params)
      render json: {
        id: @notebook.id,
        name: @notebook.name
      }
    else
      render json: { errors: @notebook.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_color
    if @notebook.update(color: params[:color])
      head :ok
    else
      render json: { errors: @notebook.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @notebook.destroy
    head :no_content
  end

  private

  def set_notebook
    @notebook = current_user.notebooks.find(params[:id])
  end

  def notebook_params
    params.require(:notebook).permit(:name, :color)
  end
end
