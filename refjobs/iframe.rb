iframeurl = "https://rpm.newrelic.com/public/charts/beplD6W7jKV"


SCHEDULER.every '20s' do

  send_event('iframe1', { url: iframeurl })

end