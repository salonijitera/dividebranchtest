json.set! :status, @status

if @status == 200
  json.message "Email verified successfully."
else
  json.error @error_message
end

# Note: Instance variables @status and @error_message should be set in the corresponding controller action
# based on the outcome of the email verification process.
