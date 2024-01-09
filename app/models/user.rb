
class User < ApplicationRecord
  # validations
  validates :username, presence: true
  validates :password, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # end for validations

  def generate_verification_token
    loop do
      token = Devise.friendly_token
      break token unless User.exists?(verification_token: token)
    end
  end

  def encrypt_password
    self.password = Devise::Encryptor.digest(User, password)
  end

  def send_confirmation_email
    UserConfirmationEmailJob.perform_later(self)
  end

  class << self
  end
end
