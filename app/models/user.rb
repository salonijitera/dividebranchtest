
class User < ApplicationRecord
  has_many :social_accounts, dependent: :destroy

  # validations
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  # end for validations

  def update_profile(id, new_email, new_password_hash)
    user = User.find_by(id: id)
    return unless user

    if new_email.present? && new_email != user.email && self.class.email_unique?(new_email)
      user.email = new_email
      user.email_verified = false
      user.verification_token = self.class.send(:generate_verification_token)
      # Send confirmation email logic here
    end

    user.password_hash = new_password_hash if new_password_hash.present?
    user.updated_at = Time.current
    user.save!
  end

  class << self
    def email_unique?(new_email)
      !User.exists?(email: new_email)
    end

    private

    def generate_verification_token
      # Token generation logic here
      SecureRandom.hex(10)
    end
  end
end
