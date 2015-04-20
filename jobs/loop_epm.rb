# TODO: Where to get error stats?
# DataDog when ready
SCHEDULER.every '1m', :first_in => 0 do |job|
  send_event('loop_epm', { current: 0, last: 0 })
end
