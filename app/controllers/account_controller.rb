class AccountController < ApplicationController
  before_action :require_authentication

  def show
    @user = current_user
    @subscription = current_user.subscription
  end

  def update
    @user = current_user
    
    if @user.update(user_params)
      redirect_to account_path, notice: "Account updated successfully"
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name)
  end
end