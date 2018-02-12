require 'rest-client'

require_relative '../assets/testrail'



SCHEDULER.every '60m', :first_in => 0 do |job|

  url = 'https://testrail.stage.mozaws.net/'
  client = TestRail::APIClient.new(url)
  client.user = ENV['TESTRAIL_USERNAME']
  client.password = ENV['TESTRAIL_PASSWORD']
  testrail_helpers = TestRail::Helpers.new(client)


  suite = 60
  audio_test_cases_counts = testrail_helpers.get_suite_stats(suite);

  suite = 55
  video_test_cases_counts = testrail_helpers.get_suite_stats(suite);

  untriaged_tasks_count = audio_test_cases_counts[1] + video_test_cases_counts[1]
  suitable_tasks_count = audio_test_cases_counts[2] + video_test_cases_counts[2]
  unsuitable_tasks_count = audio_test_cases_counts[3] + video_test_cases_counts[3]
  completed_tasks_count = audio_test_cases_counts[4] + video_test_cases_counts[4]

  total_tasks_count = audio_test_cases_counts[0] + video_test_cases_counts[0]

  send_event('testrail_audio_video_total_tasks_count', { current: total_tasks_count})
  send_event('testrail_audio_video_untriaged_tasks_count', { current: untriaged_tasks_count})
  send_event('testrail_audio_video_suitable_tasks_count', { current: suitable_tasks_count})
  send_event('testrail_audio_video_unsuitable_tasks_count', { current: unsuitable_tasks_count})
  send_event('testrail_audio_video_completed_tasks_count', { current: completed_tasks_count})

end