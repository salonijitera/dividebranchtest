require 'securerandom'
require 'uri'

class UserService
  def self.update_profile(id:, email:, password_hash:)
    user = User.find_by(id: id)
    raise ActiveRecord::RecordNotFound.new("User not found") unless user

    raise ArgumentError.new("Email cannot be empty") if email.blank?
    raise ArgumentError.new("Invalid email format") unless email =~ URI::MailTo::EMAIL_REGEXP

    if email != user.email && User.exists?(email: email)
      raise ArgumentError.new("Email is already taken")
    end

    new_password_hash = BCrypt::Password.create(password_hash)

    User.transaction do
      user.update!(email: email, password_hash: new_password_hash, updated_at: Time.current)

      if user.previous_changes.include?('email')
        user.email_verified = false
        user.verification_token = SecureRandom.hex(10)
        user.save!
        UserConfirmationEmailJob.perform_later(user_id: user.id)
      end
    end

    "User profile has been successfully updated."
  end

  def self.generate_reset_token(email)
    user = User.find_by(email: email)
    return nil unless user

    raw_token = SecureRandom.urlsafe_base64
    user.reset_token = raw_token
    user.reset_token_sent_at = Time.now.utc
    user.save(validate: false)

    UserMailer.password_reset(user).deliver_now

    "A password reset email has been sent to #{user.email}."
  end
end

# Note: UserMailer is assumed to be the mailer class responsible for sending password reset emails.
# This service class does not handle the actual sending of the email, which should be implemented in the UserMailer class.
