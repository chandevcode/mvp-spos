class UsersController < ApplicationController
  before_action :authorize_owner
  before_action :authenticate_user!

  def index
    @users = User.order(created_at: :desc)
  end

  def new
    @user = User.new
  end

  def create
    if user_params[:role] == "admin" && User.admin.count >= 2
      redirect_to users_path, alert: "Maximum 2 admin users allowed"
      return
    end

    @user = User.new(user_params)

    if @user.save
      redirect_to users_path, notice: "User created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.owner?
      redirect_to users_path, alert: "Cannot delete owner"
    else
      @user.destroy
      redirect_to users_path, notice: "User deleted"
    end
  end

  private

  def authorize_owner
    redirect_to root_path, alert: "Access denied" unless current_user.owner?
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role)
  end
end
