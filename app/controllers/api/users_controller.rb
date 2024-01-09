class Api::UsersController < ApplicationController
  before_action :find_user_by_email, only: [:reset_password]
  before_action :load_user_by_reset_token, only: [:change_password]

  # POST /api/users/reset_password
  def reset_password
    if @user
      reset_token = UserService.generate_reset_token
      @user.update(reset_token: reset_token)

      # Send the password reset email
      UserMailer.with(user: @user, token: reset_token).reset_password_instructions.deliver_later

      message = I18n.t('devise.passwords.send_instructions')
      render json: { message: message }, status: :ok
    else
      render json: { error: I18n.t('devise.failure.not_found_in_database') }, status: :not_found
    end
  end

  def change_password
    reset_token = params[:reset_token]
    password = params[:password]
    password_confirmation = params[:password_confirmation]

    if password != password_confirmation
      render json: { error: 'Password confirmation does not match.' }, status: :unprocessable_entity
      return
    end

    if @user.update(password: password, reset_token: nil)
      render json: { message: 'Password has been successfully updated.' }, status: :ok
    else
      render json: { error: 'Unable to update password.' }, status: :unprocessable_entity
    end
  end

  private

  def find_user_by_email
    @user = User.find_by(email: params[:email])
  end

  def load_user_by_reset_token
    @user = User.find_by(reset_token: params[:reset_token])
  end
end
