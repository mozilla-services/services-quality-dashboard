require 'rest-client'
require 'json'
require 'date'

defects = 0
SCHEDULER.every '60m', :first_in => 0 do |job|
  #query bugzilla for data
  last_count = defects
  # all bugs in mozilla services that were filed as 'blocker' 'critial' or 'major' in severity
  url = 'https://bugzilla.mozilla.org/rest/bug?include_fields=id&bug_severity=blocker&bug_severity=critical&bug_severity=major&product=Mozilla%20Services&chfieldfrom=2015-01-01&chfieldto=2015-03-31'
  response = RestClient.get(url)
  buglist = JSON.parse(response)
  defects = buglist["bugs"].size
  send_event('defects_qtr', { current: defects, last: last_count })
end
