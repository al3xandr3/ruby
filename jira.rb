
require 'rubygems'
require 'cgi'
require 'json'

user = "user"
pass = "pass"

# "curl -D- -u USER:PASS -X GET -H "Content-Type: application/json" "https://jira.skype.net/rest/api/latest/search?jql=assignee%3D'some.user'"
JQL = CGI.escape "assignee='some.user'"

resp = %x{ curl -u #{user}:#{pass} -X GET -H "Content-Type: application/json" "https://jira.skype.net/rest/api/latest/search?jql=#{JQL}" }

puts JSON.parse(resp)

# OR from any page do: Views -> XML
# curl -u USER:PASS -X GET "https://jira.skype.net/sr/jira.issueviews:searchrequest-xml/23211/SearchRequest-23211.xml?tempMax=1000"