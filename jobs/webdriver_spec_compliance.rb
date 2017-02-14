require 'rest-client'
require 'json'
require 'date'

avg_bug_time = 0
SCHEDULER.every '60m', :first_in => 0 do |job|
  # all bugs in operations: deployment request that are resolved
  last_avg = avg_bug_time
  url = "https://bugzilla.mozilla.org/rest/bug/721859?include_fields=id,depends_on,status"
  response = RestClient.get(url)
  depends_on = JSON.parse(response)
  total_count = 0
  resolved_count = 0
  remaining_count = 0
  resolved_pct = 0
  if depends_on["bugs"][0]["status"] != "RESOLVED"
    for depends_id in depends_on["bugs"][0]["depends_on"]
      bug_url = "https://bugzilla.mozilla.org/rest/bug/#{depends_id}?include_fields=id,depends_on,status"
      bug_response = RestClient.get(bug_url)
      bug_status = JSON.parse(bug_response)
      if bug_status["bugs"][0]["status"] == "RESOLVED"
        resolved_count += 1
      else
        remaining_count += 1
      end
      total_count += 1
    end
  end

  resolved_pct = ((resolved_count.to_f / total_count.to_f) * 100).round(2)

  send_event('webdriver_total_issues', { current: total_count, last: 0 })
  send_event('webdriver_pct_resolved', { value: resolved_pct})
  send_event('webdriver_bugs_open', { current: remaining_count, last: 0 })
end
