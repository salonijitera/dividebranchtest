
class SocialAccount < ApplicationRecord
  belongs_to :user

  enum provider: %w[facebook google twitter linkedin], _suffix: true

  # validations
  validates :provider, presence: true, inclusion: { in: providers.keys }
  validates :provider_user_id, presence: true
  validates :access_token, presence: true
  # end for validations

  class << self
    def register_with_social(provider, provider_user_id, access_token)
      transaction do
        social_account = find_or_initialize_by(provider: provider, provider_user_id: provider_user_id)
        unless social_account.user
          user = User.create!(created_at: Time.current, updated_at: Time.current)
          social_account.update!(user: user, access_token: access_token, created_at: Time.current, updated_at: Time.current)
        end
        social_account.user_id
      end
    end
  end
end
