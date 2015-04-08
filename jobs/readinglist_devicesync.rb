# TODO: Where to get uptime stats?
SCHEDULER.every '30m', :first_in => 0 do |job|
  send_event('rl_syncing_time', { current: 6.23, last: 0 })
end
