#!/usr/bin/env ruby
require 'net/http'
require 'uri'

# Check whether a server is responding
# you can set a server to check via http request or ping
#
# server options:
# name: how it will show up on the dashboard
# url: either a website url or an IP address (do not include https:// when usnig ping method)
# method: either 'http' or 'ping'
# if the server you're checking redirects (from http to https for example) the check will
# return false

servers = [{name: 'Rackroom Production website', url: 'http://www.offbroadwayshoes.com/welcome.html', method: 'http'},
    {name: 'Rackroom Dev website', url: 'http://offbroadwayshoes.dev:9001/welcome.html', method: 'http'} ,
    {name: 'Rackroom QA website', url: 'http://stage.offbroadwayshoes.com/welcome.html', method: 'http'}
]

SCHEDULER.every '300s', :first_in => 0 do |job|

	statuses = Array.new
	
	# check status for each server
	servers.each do |server|
		begin
		puts "Checking server:" + server[:name]
		if server[:method] == 'http'
			uri = URI.parse(server[:url])
			http = Net::HTTP.new(uri.host, uri.port)
			puts uri.host
			puts uri.port
			puts uri.request_uri	
			if uri.scheme == "https"
				http.use_ssl=true
				http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			end
			request = Net::HTTP::Get.new(uri.request_uri)
			response = http.request(request)
			if response.code == "200" || response.code == "302"
			 	result = 1
			 	puts "Response is:" + response.code
			 else
			 	result = 0
			 	puts "Response is:" + response.code
			 end
		elsif server[:method] == 'ping'
			ping_count = 10
			result = `ping -q -c #{ping_count} #{server[:url]}`
			if ($?.exitstatus == 0)
				result = 1
			else
				result = 0
			end
		end
		rescue Exception => e
			puts "Exception while checking server" + e.message
			result = 0
		end
		if result == 1
			arrow = "icon-ok-sign"
			color = "green"
		else
			arrow = "icon-warning-sign"
			color = "red"
		end

		statuses.push({label: server[:name], value: result, arrow: arrow, color: color})
	end

	# print statuses to dashboard
	send_event('rackroom_server_status', {items: statuses})
end