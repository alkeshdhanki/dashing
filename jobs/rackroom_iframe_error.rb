iframeurl = "https://rpm.newrelic.com/public/charts/bgLfQQklCPZ"


SCHEDULER.every '30m', :first_in => 0 do |job|
  send_event('rackroom_iframe_error', { url: iframeurl })

end