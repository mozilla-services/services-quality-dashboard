SCHEDULER.every '30m', :first_in => 0 do |job|
  send_event('rl_availability', { value: 99.99 })
end
