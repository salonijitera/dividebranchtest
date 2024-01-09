require 'active_support/all'

module UserService
  class LinkSocialAccount < BaseService
    def call(user_id:, provider:, provider_user_id:, access_token:)
      user = User.find_by(id: user_id)
      raise 'User not found' unless user

      unless SocialAccount.providers.keys.include?(provider)
        raise 'Unsupported provider'
      end

      if SocialAccount.exists?(user_id: user_id, provider: provider, provider_user_id: provider_user_id)
        raise 'Social account is already linked to another user'
      end

      social_account = user.social_accounts.create!(
        provider: provider,
        provider_user_id: provider_user_id,
        access_token: access_token,
        created_at: Time.current,
        updated_at: Time.current
      )

      raise 'Unable to link social account' unless social_account.persisted?

      'Social account has been successfully linked'
    end
  end
end
