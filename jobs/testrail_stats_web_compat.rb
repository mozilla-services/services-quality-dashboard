require 'rest-client'

require_relative '../assets/testrail'



SCHEDULER.every '60m', :first_in => 0 do |job|

  url = 'https://testrail.stage.mozaws.net/'
  client = TestRail::APIClient.new(url)
  client.user = ENV['TESTRAIL_USERNAME']
  client.password = ENV['TESTRAIL_PASSWORD']
  testrail_helpers = TestRail::Helpers.new(client)


  suite = 63
  test_cases_counts = testrail_helpers.get_suite_stats(suite);
  untriaged_tasks_count = test_cases_counts[1]
  suitable_tasks_count = test_cases_counts[2]
  unsuitable_tasks_count = test_cases_counts[3]
  completed_tasks_count = test_cases_counts[4]
  total_tasks_count = test_cases_counts[0]

  send_event('testrail_web_compat_total_tasks_count', { current: total_tasks_count})
  send_event('testrail_web_compat_untriaged_tasks_count', { current: untriaged_tasks_count})
  send_event('testrail_web_compat_suitable_tasks_count', { current: suitable_tasks_count})
  send_event('testrail_web_compat_unsuitable_tasks_count', { current: unsuitable_tasks_count})
  send_event('testrail_web_compat_completed_tasks_count', { current: completed_tasks_count})

end