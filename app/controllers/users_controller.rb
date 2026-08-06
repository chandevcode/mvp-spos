class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_owner
  before_action :set_user, only: [ :edit, :update, :destroy ]

  def index
    @users = User.order(created_at: :desc)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    raw_password = user_params[:password]

    if @user.save
      UserMailer.credentials_email(@user, raw_password).deliver_later
      redirect_to users_path, notice: "User created successfully. Credentials have been sent via email."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    raw_password = user_params[:password]

    if @user.update(user_params)
      if raw_password.present?
        UserMailer.credentials_email(@user, raw_password).deliver_later
        notice_msg = "User updated. New credentials have been sent via email."
      else
        notice_msg = "User updated successfully."
      end
      redirect_to users_path, notice: notice_msg
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
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

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
  end
end
