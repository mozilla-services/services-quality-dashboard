require 'rest-client'
require 'json'
require 'date'

avg_bug_time = 0
SCHEDULER.every '60m', :first_in => 0 do |job|
  # all bugs in operations: deployment request that are resolved
  last_avg = avg_bug_time
  url = 'https://bugzilla.mozilla.org/rest/bug?include_fields=id,cf_last_resolved,creation_time,&product=Cloud%20Services&resolution=FIXED&chfieldfrom=2015-01-01'
  response = RestClient.get(url)
  buglist = JSON.parse(response)
  diffs = []
  if buglist["bugs"]
    for bug in buglist["bugs"]
      if bug["cf_last_resolved"]
        resolved_time = DateTime.parse(bug["cf_last_resolved"])
        created_time = DateTime.parse(bug["creation_time"])
        if resolved_time > created_time
          diff = (resolved_time - created_time).to_f
          if diff < 21 #exclude outliers
            diffs << diff
          end
        end
      end
    end
  end
  avg_bug_time = diffs.reduce(:+) / diffs.size
  data = []
  diffs.each_with_index do |k, v|
    data << {"x" => v, "y" => k.round(2)}
  end
  send_event('bug_cycle', points: data, displayedValue: avg_bug_time.round(2))
end
