module UserService
  class ResetPassword < BaseService
    def call(reset_token, password, password_confirmation)
      raise StandardError.new(I18n.t('devise.passwords.password_mismatch')) unless password == password_confirmation

      user = User.find_by(reset_token: reset_token)
      raise StandardError.new(I18n.t('errors.messages.not_found')) if user.nil?

      user.password = Devise::Encryptor.digest(User, password)
      user.reset_token = nil
      user.save!

      I18n.t('devise.passwords.updated')
    rescue ActiveRecord::RecordInvalid => e
      raise StandardError.new(e.record.errors.full_messages.to_sentence)
    end
  end
end

# Note: The above code assumes that the User model has a method for password encryption
# and that the BaseService class exists and provides a common structure for service objects.
# It also assumes that the I18n translations are set up correctly in the devise.en.yml file.
# The error messages are using the Devise and ActiveRecord locales for user-friendly messages.
# The `save!` method is used to raise an exception if the record is invalid.
# The `StandardError` is raised with a message that can be displayed to the user.
# The `I18n.t` method is used to fetch the localized strings.
