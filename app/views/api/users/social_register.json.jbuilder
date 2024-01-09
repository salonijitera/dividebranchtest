json.status 201
json.message "User registered successfully with social login."
json.user do
  json.id @user.id
  json.email @user.email
  json.created_at @user.created_at.iso8601
end
json.social_account do
  json.provider @social_account.provider
  json.provider_user_id @social_account.provider_user_id
end
