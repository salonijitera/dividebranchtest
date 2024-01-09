class UserAuthenticationService < BaseService
  def self.authenticate_user(username, password)
    user = User.find_by(username: username)

    if user.nil?
      return { error: I18n.t('devise.failure.not_found_in_database', authentication_keys: 'username') }
    end

    if user.valid_password?(password)
      token = CustomAccessToken.create(resource_owner_id: user.id)
      return { token: token.token }
    else
      return { error: I18n.t('devise.failure.invalid', authentication_keys: 'password') }
    end
  rescue StandardError => e
    return { error: e.message }
  end
end

# BaseService class is assumed to be part of the application's architecture.
# If it does not exist, UserAuthenticationService can directly inherit from ApplicationRecord or another appropriate base class.
# The I18n.t method is used to fetch the appropriate error message from the locale files.
# CustomAccessToken is assumed to be a model that includes the Doorkeeper::AccessToken module or similar functionality for token management.
# The 'valid_password?' method is provided by Devise for the User model to check if the password is correct.
# The 'find_by' method is a standard ActiveRecord method to retrieve a record by a given attribute.
# The error messages are assumed to be defined in the locale files under the 'devise.failure' namespace.
# The 'create' method on CustomAccessToken is assumed to generate a new token; this may need to be adjusted based on actual implementation.
