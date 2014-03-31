iframeurl = "https://rpm.newrelic.com/public/charts/7tqLT8AHwXu"


SCHEDULER.every '30m', :first_in => 0 do |job|

  send_event('rackroom_iframe_cpu', { url: iframeurl })

end