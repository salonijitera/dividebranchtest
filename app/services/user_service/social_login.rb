module UserService
  class SocialLogin < BaseService
    def self.call(provider:, provider_user_id:, access_token:)
      # Validate the provider against the supported enum types
      unless SocialAccount.providers.keys.include?(provider)
        raise ArgumentError, "Unsupported provider"
      end

      # Check if a social account exists with the given provider and provider_user_id
      social_account = SocialAccount.find_or_initialize_by(
        provider: provider,
        provider_user_id: provider_user_id
      )

      if social_account.new_record?
        # Create a new user with null email and password_hash fields
        user = User.create!(created_at: Time.current, updated_at: Time.current)
        # Create a new social account record
        social_account.user = user
        social_account.access_token = access_token
        social_account.created_at = Time.current
        social_account.updated_at = Time.current
        social_account.save!
      else
        # Retrieve the associated user's information
        user = social_account.user
      end

      # Return the user ID of the newly created or existing user
      user.id
    end
  end
end
