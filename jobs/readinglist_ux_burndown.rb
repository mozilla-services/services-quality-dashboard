require 'rest-client'
require 'json'

complete_percent = 41
SCHEDULER.every '30m', :first_in => 0 do |job|
  # all bugs in operations: deployment request that are resolved
  last_percent = complete_percent
  send_event('rl_ux_burndown', { current: complete_percent.round(2), last: last_percent })
end
