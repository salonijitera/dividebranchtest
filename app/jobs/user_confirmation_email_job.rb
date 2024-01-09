
class UserConfirmationEmailJob < ApplicationJob
  queue_as :default

  def perform(user)
    UserMailer.confirmation_instructions(user, user.verification_token)
              .deliver_later
  end
end
