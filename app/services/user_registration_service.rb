require 'app/models/user.rb'

class UserRegistrationService < BaseService
  def register_user(username:, password:, email:)
    raise ArgumentError, 'Username cannot be blank' if username.blank?
    raise ArgumentError, 'Password cannot be blank' if password.blank?
    raise ArgumentError, 'Email cannot be blank' if email.blank?

    unless email =~ URI::MailTo::EMAIL_REGEXP
      raise ArgumentError, 'Invalid email format'
    end

    if User.exists?(email: email)
      raise ArgumentError, 'Email is already taken'
    end

    encrypted_password = User.new(password: password).encrypted_password
    verification_token = SecureRandom.hex(10)

    user = User.create!(
      username: username,
      password: encrypted_password,
      email: email,
      email_verified: false,
      verification_token: verification_token
    )

    EmailService.sendEmail(
      to: email,
      subject: I18n.t('devise.mailer.confirmation_instructions.subject'),
      body: I18n.t('devise.mailer.confirmation_instructions.instruction') + verification_token
    )

    { message: I18n.t('devise.registrations.signed_up_but_unconfirmed') }
  rescue StandardError => e
    { error: e.message }
  end
end

class BaseService
end

class EmailService
  def self.sendEmail(to:, subject:, body:)
    # Implementation for sending email
  end
end
