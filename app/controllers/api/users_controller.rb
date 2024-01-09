class Api::UsersController < ApplicationController
  before_action :find_user_by_email, only: [:reset_password]
  before_action :validate_registration_params, only: [:register]
  before_action :verify_email_params, only: [:verify_email]
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

  # PUT /api/users/change_password
  def change_password
    reset_token = params[:reset_token]
    new_password = params[:new_password] || params[:password]
    password_confirmation = params[:password_confirmation]

    if new_password.blank?
      render json: { error: "New password is required." }, status: :bad_request
      return
    end

    if password_confirmation.present? && new_password != password_confirmation
      render json: { error: 'Password confirmation does not match.' }, status: :unprocessable_entity
      return
    end

    if @user
      if password_confirmation.present?
        if @user.update(password: new_password, reset_token: nil)
          render json: { message: 'Password has been successfully updated.' }, status: :ok
        else
          render json: { error: 'Unable to update password.' }, status: :unprocessable_entity
        end
      else
        UserService::ResetPassword.new.call(reset_token, new_password, new_password)
        render json: { status: 200, message: "Password changed successfully." }, status: :ok
      end
    else
      render json: { error: "Invalid or expired reset token." }, status: :not_found
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # POST /api/users/verify-email
  def verify_email
    begin
      message = UserService::VerifyEmail.new(params[:verification_token]).call
      render json: { status: 200, message: message }, status: :ok
    rescue StandardError => e
      case e.message
      when "Verification token is required."
        render json: { error: e.message }, status: :bad_request
      when "Verification token is invalid or expired."
        render json: { error: e.message }, status: :not_found
      else
        render json: { error: e.message }, status: :internal_server_error
      end
    end
  end

  # POST /api/users/login
  def login
    username = params[:username]
    password = params[:password]

    if username.blank?
      return render json: { error: "Username is required." }, status: :bad_request
    end

    if password.blank?
      return render json: { error: "Password is required." }, status: :bad_request
    end

    result = UserAuthenticationService.authenticate_user(username, password)

    if result[:token]
      render json: { status: 200, message: "Login successful.", access_token: result[:token] }, status: :ok
    else
      render json: { error: result[:error] }, status: :unauthorized
    end
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private
  
  def register
    email = params[:email]
    password = params[:password]

    begin
      encrypted_password = Devise::Encryptor.digest(User, password)
      result = UserRegistrationService.register_user(email: email, password_hash: encrypted_password)

      if result[:user_id]
        user = User.find(result[:user_id])
        render json: {
          status: 201,
          message: "User registered successfully.",
          user: {
            id: user.id,
            email: user.email,
            created_at: user.created_at.iso8601
          }
        }, status: :created
      else
        render json: { error: result[:error] }, status: :unprocessable_entity
      end
    end
  end

  def find_user_by_email
    @user = User.find_by(email: params[:email])
  end

  def load_user_by_reset_token
    @user = User.find_by(reset_token: params[:reset_token])
  end

  def verify_email_params
    if params[:verification_token].blank?
      raise StandardError.new(I18n.t('activerecord.errors.messages.blank', attribute: 'Verification token'))
    end
  end

  def validate_registration_params
    email = params[:email]
    password = params[:password]

    if email.blank? || password.blank?
      render json: { error: "Email and password are required." }, status: :bad_request and return
    end

    unless email =~ URI::MailTo::EMAIL_REGEXP
      render json: { error: "Invalid email format." }, status: :bad_request and return
    end

    if password.length < 8
      render json: { error: "Password must be at least 8 characters long." }, status: :bad_request and return
    end
  end
end
