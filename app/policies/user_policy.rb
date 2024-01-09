class UserPolicy < ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def link_social_account?
    user.present? && record.id == user.id
  end
end
