require 'securerandom'

class UserService
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
