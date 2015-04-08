# TODO: Where to get availability stats?
SCHEDULER.every '30m', :first_in => 0 do |job|
  send_event('rl_readability_topsites', { value: 25 })
end
