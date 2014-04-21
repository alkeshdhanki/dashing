require 'google/api_client'
require 'date'
 
# Update these to match your own apps credentials
service_account_email = ENV['rackroom.ga.service_account_email'] # Email of service account
key_file = ENV['rackroom.ga.key_file'] # File containing your private key
key_secret = ENV['rackroom.ga.key_secret'] # Password to unlock private key
profileID = ENV['rackroom.ga.profileID'] # Analytics profile ID.

# Get the Google API client
client = Google::APIClient.new(
  :application_name => 'arvato_rackroom_ga', 
  :application_version => '0.01'
)
 
visitors = []
 
# Load your credentials for the service account
key = Google::APIClient::KeyUtils.load_from_pkcs12(key_file, key_secret)
client.authorization = Signet::OAuth2::Client.new(
  :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  :audience => 'https://accounts.google.com/o/oauth2/token',
  :scope => 'https://www.googleapis.com/auth/analytics.readonly',
  :issuer => service_account_email,
  :signing_key => key)
 
# Start the scheduler
SCHEDULER.every '10s', :first_in => 0 do
 
  # Request a token for our service account
  client.authorization.fetch_access_token!
 
  # Get the analytics API
  analytics = client.discovered_api('analytics','v3')
 
  # Execute the query
  visitCount = client.execute(:api_method => analytics.data.realtime.get, :parameters => { 
    'ids' => "ga:" + profileID,
    'metrics' => "rt:activeVisitors",
  })
 
  # Update the dashboard
  send_event('rackroom_visitor_count', current: visitCount.data.rows[0][0].to_i)
end