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

servers = [{name: 'Benefit US site', url: 'http://origin.benefitcosmetics.com', method: 'http'},
		{name: 'Benefit  FR site', url: 'http://origin.benefitcosmetics.fr/en_FR/', method: 'http'} ,
    {name: 'Benefit  DE site', url: 'http://origin.benefitcosmetics.de/en_DE/', method: 'http'} ,
    {name: 'Benefit  UK site', url: 'http://origin.benefitcosmetics.co.uk', method: 'http'} ,
    {name: 'Exact Target', url: 'http://webservice.s4.exacttarget.com', method: 'http'} ,
    {name: 'OMS Biztalk service', url: 'http://biztalk.arvatousa.com/Benefit.BizTalk.Orchestrations_Proxy/Benefit_BizTalk_Orchestrations_CreateOrder_Process_CreateOrderPort.asmx', method: 'http'} ,
    {name: 'Payment gateway', url: 'https://paygw.csservice.arvato-systems.de/v6.10/PMG.Services/V2/TransactionWebservice.svc?wsdl', method: 'http'}
]

SCHEDULER.every '300s', :first_in => 0 do |job|

	statuses = Array.new
	
	# check status for each server
	servers.each do |server|
		if server[:method] == 'http'
			uri = URI.parse(server[:url])
			http = Net::HTTP.new(uri.host, uri.port)
			if uri.scheme == "https"
				http.use_ssl=true
				http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			end
			request = Net::HTTP::Get.new(uri.request_uri)
			response = http.request(request)
			if response.code == "200"
			 	result = 1
			 else
			 	result = 0
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
	send_event('server_status', {items: statuses})
end