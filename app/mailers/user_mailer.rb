class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def reset_password_instructions(user, token)
    @user = user
    @token = token
    mail(to: @user.email, subject: I18n.t('devise.mailer.reset_password_instructions.subject')) do |format|
      format.html { render 'reset_password_instructions', locals: { user: @user, token: @token } }
    end
  end
end
