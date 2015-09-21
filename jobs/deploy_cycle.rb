require 'rest-client'
require 'json'
require 'date'

avg_deploy_time = 0
SCHEDULER.every '60m', :first_in => 0 do |job|
  # all bugs in operations: deployment that are resolved for this quarter
  last_avg = avg_deploy_time
  url = 'https://bugzilla.mozilla.org/rest/bug?include_fields=id,summary,cf_last_resolved,creation_time,&component=Operations%3A%20Deployment%20Requests&resolution=FIXED&chfieldfrom=2015-01-01'
  response = RestClient.get(url)
  buglist = JSON.parse(response)
  diffs = []
  for bug in buglist["bugs"]
    resolved_time = DateTime.parse(bug["cf_last_resolved"])
    created_time = DateTime.parse(bug["creation_time"])
    summary = bug["summary"]
    if resolved_time > created_time and (summary.include?('prod') or summary.include?('production'))
      diff = (resolved_time - created_time).to_f
      if diff < 100 #exclude outliers
        diffs << diff
      end
      # diffs << diff
    end
  end
  avg_deploy_time = diffs.reduce(:+) / diffs.size
  data = []
  diffs.each_with_index do |k, v|
    data << {"x" => v, "y" => k.round(2)}
  end
  send_event('deploy_cycle', points: data, displayedValue: avg_deploy_time.round(2))
end
