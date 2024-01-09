if @error.present?
  json.error @error
else
  json.status 200
  json.message "Login successful."
  json.access_token @access_token
end
