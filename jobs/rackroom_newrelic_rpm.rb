require 'newrelic_api'

# Newrelic API key
key = '0f8a22540ec72ad929adbf5c199f9e4e5d0161b835f97f3'

# Monitored application
app_ids = ['3051262']


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

SCHEDULER.every '300s', :first_in => 0 do |job|

  app_ids.each do |appid|
  newrelicapp = NewRelicApi::Account.find(:first).applications.select{|app| app.id.to_s == appid }.first

    newrelicapp.threshold_values.each do |v|
      puts appid + "_" + v.name.downcase.gsub(/ /, '_')
      puts v.metric_value
    	send_event(appid + "_" + v.name.downcase.gsub(/ /, '_'), { current: v.metric_value })
      	send_event(appid + "_" + v.name.downcase.gsub(/ /, '_'), { value: v.metric_value })
    end
  end
end
