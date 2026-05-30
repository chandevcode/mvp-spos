class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_owner

  def index
    @users = User.where(role: :admin).order(created_at: :desc)
  end

  def new
    if User.admin.count >= 3
      redirect_to users_path, alert: "Maximum 2 admin users allowed"
      return
    end
    @user = User.new
  end

  def create
    if User.admin.count >= 3
      redirect_to users_path, alert: "Maximum 2 admin users allowed"
      return
    end

    @user = User.new(user_params)
    @user.role = :admin

    if @user.save
      redirect_to users_path, notice: "Admin user created successfully"
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
      redirect_to users_path, notice: "Admin user deleted"
    end
  end

  private

  def authorize_owner
    redirect_to root_path, alert: "Access denied" unless current_user.owner?
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
