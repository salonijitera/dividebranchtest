
require 'app/models/user.rb'
require 'devise/encryptor'

class UserRegistrationService < BaseService
  def register_user(email:, password_hash:)
    raise ArgumentError, 'Email cannot be blank' if email.blank?

    unless email =~ URI::MailTo::EMAIL_REGEXP
      raise ArgumentError, 'Invalid email format'
    end

    if User.exists?(email: email)
      raise ArgumentError, 'Email is already taken'
    end

    encrypted_password = Devise::Encryptor.digest(User, password_hash)
    verification_token = SecureRandom.hex(10)

    user = User.create(
      email: email,
      password_hash: encrypted_password,
      email_verified: false,
      verification_token: verification_token,
      created_at: DateTime.current,
      updated_at: DateTime.current
    )

    UserConfirmationEmailJob.perform_later(user_id: user.id)

    { user_id: user.id }
  rescue StandardError => e
    { error: e.message }
  end
end

class BaseService
end

class UserConfirmationEmailJob
  def self.perform_later(user_id:)
    # Implementation for sending confirmation email asynchronously
  end
end

class User < ApplicationRecord
  # User model implementation
end
