module UserService
  class VerifyEmail < BaseService
    def initialize(verification_token)
      super()
      @verification_token = verification_token
    end

    def call
      user = User.find_by(verification_token: @verification_token)

      if user
        user.update(email_verified: true, verification_token: nil)
        "Email has been successfully verified."
      else
        raise StandardError.new "Verification token is invalid or expired."
      end
    rescue => e
      logger.error "Email verification failed: #{e.message}"
      raise
    end
  end
end

