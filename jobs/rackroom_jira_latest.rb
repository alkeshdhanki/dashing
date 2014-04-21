require 'rest-client'
require 'uri'
require 'date'

username = ENV['rackroom.jira.username']
password = ENV['rackroom.jira.password']
projectkey = ENV['rackroom.jira.projectkey']

resturl= ENV['rackroom.jira.resturl']
searchpath='search?jql=project='+projectkey+' order by created'


SCHEDULER.every '1h', :first_in => 0 do |job|

	searchoptions = {
    	:method => :get,
    	:url => URI::encode(resturl+searchpath),
    	:user => username,
    	:password => password,
    	:timeout => 20,
    	:headers => { :accept => :json,
    	:content_type => :json }
	}

  searchclient = RestClient::Request.new(searchoptions)


  response2 = searchclient.execute
  results2 = JSON.parse(response2.to_str)
  puts results2['issues'].length
    if results2['issues'].length>0
    	issues = Array.new
    	header=Array.new
    	header.push("Created")
    	header.push("Ticket")
   		header.push("Summary")
    	header.push("Assignee")
    	header.push("Resolution")
    	issues.push(header)
		results2['issues'].each do |issue|
		    if issues.size <=10
		    	row=Array.new
    			row.push(issue['fields']['created'].slice(0,16))
    			row.push(issue['key'])
    			row.push(issue['fields']['summary'])
    			if issue['fields']['assignee'] 
    				row.push(issue['fields']['assignee']['displayName'])
    			else
    				row.push("Unassigned");
    			end
    			if issue['fields']['resolution'] 
    				row.push(issue['fields']['resolution']['name'])
    			else
    				row.push("Unresolved");
    			end
    			issues.push(row)
    		end
		end
	else
		issues = Array.new
    	header=Array.new
   		header.push("No Issues Found for the Project")
    	issues.push(header)
    end


send_event('rackroom_jira_latest', {rows: issues})


end
