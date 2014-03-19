require 'newrelic_api'

# Newrelic API key
key = '09c03ce822de0f03be5282cc87bec74ee6a534d4c9f7126'

# Monitored application
app_ids = ['320534']


# Emitted metrics:
# - _apdex
# - _error_rate
# - _throughput
# - _errors
# - _response_time
# - _db
# - _cpu
# - _memory

NewRelicApi.api_key = key

SCHEDULER.every '10s', :first_in => 0 do |job|

  app_ids.each do |appid|
  newrelicapp = NewRelicApi::Account.find(:first).applications.select{|app| app.id.to_s == appid }.first

    newrelicapp.threshold_values.each do |v|
      #puts appid + "_" + v.name.downcase.gsub(/ /, '_')
      #puts v.metric_value
        send_event(appid + "_" + v.name.downcase.gsub(/ /, '_'), { value: v.metric_value })
      send_event(appid + "_" + v.name.downcase.gsub(/ /, '_'), { current: v.metric_value })
    end
  end
end
