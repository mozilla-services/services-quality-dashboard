require 'rest-client'
require 'json'

complete_percent = 0
SCHEDULER.every '60m', :first_in => 0 do |job|
  last_avg = complete_percent
  # add whitelist tag when all tickets are in
  url = 'https://bugzilla.mozilla.org/rest/bug?include_fields=id,summary,status&component=QA%3A%20Test%20Automation&product=Cloud%20Services'
  response = RestClient.get(url)
  buglist = JSON.parse(response)
  completed_bugs = 0
  total_bugs = buglist["bugs"].size
  for bug in buglist["bugs"]
    if ["RESOLVED"].include?(bug["status"])
      completed_bugs += 1
    end
  end
  complete_percent = (completed_bugs.to_f/total_bugs.to_f) * 100
  send_event('coverage', { value: complete_percent.round(2) })
end
