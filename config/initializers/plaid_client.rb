plaid_creds = Rails.application.credentials.plaid

PLAID_CLIENT = Plaid::Client.new({
  env: plaid_creds[:env],
  client_id: plaid_creds[:client_id],
  secret: plaid_creds[:secrets][:development],
  public_key: plaid_creds[:public_key]
})
