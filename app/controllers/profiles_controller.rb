class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
    @tenant = current_user.tenant
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to edit_profile_path, notice: "Profile updated successfully"
    else
      @tenant = current_user.tenant
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation).tap do |p|
      p.delete(:password) if p[:password].blank?
      p.delete(:password_confirmation) if p[:password_confirmation].blank?
    end
  end
end
