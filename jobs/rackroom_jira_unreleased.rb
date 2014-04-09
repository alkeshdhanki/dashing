require 'rest-client'
require 'uri'

username = "alkesh.dhanki@arvatosystems.com"
password = "alkesh.dhanki"
projectkey = "OBSO"

resturl='https://www.arvatosystems-us.com/jira/rest/api/2/'
versionspath='project/'+projectkey+'/versions'
searchpath='search?jql='

versionsoptions = {
    :method => :get,
    :url => resturl+versionspath,
    :user => username,
    :password => password,
    :timeout => 20,
    :headers => { :accept => :json,
    :content_type => :json }
}



SCHEDULER.every '1h', :first_in => 0 do |job|

  versionsclient = RestClient::Request.new(versionsoptions)


  response = versionsclient.execute
  unreleasedversions=Array.new 
  results = JSON.parse(response.to_str)
	results.each do |v|
		if v['released'] == false
			unreleasedversions.push(v['id'])
		end
	end

if unreleasedversions.length > 0
	searchpath=searchpath+'fixVersion in ('
	unreleasedversions.each do |uv|
		searchpath=searchpath+uv+','
	end
	searchpath=searchpath.chop
	searchpath=searchpath+')&project='+projectkey



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
    if results2['issues'].length>0
    	issues = Array.new
    	header=Array.new
    	header.push("Ticket")
   		header.push("Summary")
   		header.push("Assignee")
    	header.push("Resolution")
    	issues.push(header)
		results2['issues'].each do |issue|
		    row=Array.new
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
	else
		issues = Array.new
    	header=Array.new
   		header.push("No Issues in Unreleased Versions")
    	issues.push(header)
    end
else
	issues = Array.new
    header=Array.new
    header.push("No Unreleased Versions")
    issues.push(header)
end

send_event('rackroom_jira_unreleased', {rows: issues})


end
