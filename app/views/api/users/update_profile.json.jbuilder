json.status 200
json.message 'User profile updated successfully.'
json.user do
  json.id @user.id
  json.email @user.email
  json.updated_at @user.updated_at.iso8601
end
