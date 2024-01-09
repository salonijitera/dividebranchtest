.status 201
json.message "User registered successfully."
json.user do
  json.id @user.id
  json.email @user.email
  json.created_at @user.created_at.iso8601
end
