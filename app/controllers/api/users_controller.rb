class Api::UsersController < ApplicationController
  before_action :find_user_by_email, only: [:reset_password]

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

  private

  def find_user_by_email
    @user = User.find_by(email: params[:email])
  end
end
