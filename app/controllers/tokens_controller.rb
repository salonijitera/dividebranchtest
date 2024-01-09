# frozen_string_literal: true

require 'user_service/verify_email'
class TokensController < Doorkeeper::TokensController
  # callback
  before_action :validate_resource_owner

  # POST /login
  def create
    username = params[:username]
    password = params[:password]

    user = User.find_by(username: username)

    if user && user.authenticate(password)
      # Assuming UserAuthenticationService is available and it has a method to generate token
      token = UserAuthenticationService.generate_token_for(user)
      render json: { token: token }, status: :ok
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end

  # POST /verify
  def verify
    verification_token = params[:verification_token]

    if verification_token.blank?
      render json: { error: I18n.t('errors.messages.not_found') }, status: :unprocessable_entity
      return
    end

    user = UserService::VerifyEmail.call(verification_token)

    if user
      render json: { message: I18n.t('devise.confirmations.confirmed') }, status: :ok
    else
      render json: { error: I18n.t('errors.messages.expired') }, status: :unprocessable_entity
    end
  end

  private

  # methods

  def validate_resource_owner
    return if resource_owner.blank?

    if resource_owner_locked?
      render json: {
        error: I18n.t('common.errors.token.locked'),
        message: I18n.t('common.errors.token.locked')
      }, status: :unauthorized
    end
    return if resource_owner_confirmed?

    render json: {
             error: I18n.t('common.errors.token.inactive'),
             message: I18n.t('common.errors.token.inactive')
           },
           status: :unauthorized
  end

  def resource_owner
    return nil if action_name == 'revoke'

    return unless authorize_response.respond_to?(:token)

    authorize_response&.token&.resource_owner
  end

  def resource_owner_locked?
    resource_owner.access_locked?
  end

  def resource_owner_confirmed?
    # based on condition jitera studio
    # This method should contain the logic to check if the resource owner is confirmed.
    # The actual implementation depends on the application's requirements.
    # For example, it might check a 'confirmed' or 'active' attribute on the user model.
  end

  # Add more private methods if needed

end
