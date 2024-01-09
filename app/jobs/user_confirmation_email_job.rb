class UserConfirmationEmailJob < ApplicationJob
  queue_as :default

  def perform(user_id:)
    user = User.find_by(id: user_id)
    return if user.nil?

    # Assuming EmailService and its sendEmail method are defined elsewhere in the application
    email_subject = I18n.t('devise.mailer.confirmation_instructions.subject')
    email_body = ApplicationController.render(
      template: 'devise/mailer/confirmation_instructions',
      locals: { email: user.email, token: user.verification_token }
    )

    EmailService.new.sendEmail(
      to: user.email,
      subject: email_subject,
      body: email_body
    )
  end
end
