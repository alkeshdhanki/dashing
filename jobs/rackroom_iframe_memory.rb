iframeurl = "https://rpm.newrelic.com/public/charts/hLfn9rWrtHJ"


SCHEDULER.every '30m', :first_in => 0 do |job|
  send_event('rackroom_iframe_memory', { url: iframeurl })

end