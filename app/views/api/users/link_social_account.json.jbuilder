json.status @status
json.message @message

if @status == 200
  json.social_account do
    json.user_id @social_account.user_id
    json.provider @social_account.provider
    json.provider_user_id @social_account.provider_user_id
    json.created_at @social_account.created_at.iso8601
  end
end
