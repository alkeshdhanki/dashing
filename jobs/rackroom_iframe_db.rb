iframeurl = "https://rpm.newrelic.com/public/charts/lDF7quPERH8"


SCHEDULER.every '30m', :first_in => 0 do |job|

  send_event('rackroom_iframe_db', { url: iframeurl })

end