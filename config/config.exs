use Mix.Config
#
# Marketo Configuration
#
# Note:  The API throttling rate has a maximum rate of 100 calls for every 20 seconds.
#        Please take this into consideration when setting the throttling rate.
#
config :exmarketo,
  endpoint: "",            # URL for the Marketo REST API
  client_id: "",           # Client ID for REST services
  client_secret: "",       # Client Secret for REST services
  api_throttle_rate: 250,  # Time in milliseconds to wait before subsequent REST calls
  timeout: 20000           # Time in milliseconds to wait before timing out REST calls
