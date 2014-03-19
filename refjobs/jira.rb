require 'jira'

username = "erik.wennerberg@arvatosystems.com"
password = "test56"
projectkey = "BCOP"

options = {
    :username => username,
    :password => password,
    :site     => 'https://www.arvatosystems-us.com',
    :context_path => '/jira',
    :auth_type => :basic
}



SCHEDULER.every '10h', :first_in => 0 do |job|

  client = JIRA::Client.new(options)

# Show all projects
  project = client.Project.find(projectkey)

  issues = Array.new
  project.issues.each do |issue|
    #puts issue.key
    if issues.size < 8
    issues.push({label: issue.key, value: issue.summary})
    end
  end
  send_event('jira_issues', {items: issues})
  #issue.comments.each {|comment| ... }


end
