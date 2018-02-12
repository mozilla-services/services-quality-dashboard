require 'rest-client'

require_relative '../assets/bugzilla'



SCHEDULER.every '60m', :first_in => 0 do |job|

  url = 'https://bugzilla.mozilla.org/'
  client = BugZilla::APIClient.new(url)
  client.user = ENV['BUGZILLA_USERNAME']
  client.password = ENV['BUGZILLA_PASSWORD']
  bugzilla_helpers = BugZilla::Helpers.new(client)


  #no meta bug was logged here, just some old bugs
  #Bug 1136641 - Add automated test for playing various audio formats
  #Bug 1136640 - Add test for various video formats
  blockedId = '1136641,1136640'

  status = nil
  total_bugs_count = bugzilla_helpers.get_count_of_multiple_bugs_by_ids(blockedId, status);

  status = 'NEW'
  total_new_bugs_count = bugzilla_helpers.get_count_of_multiple_bugs_by_ids(blockedId, status);

  status = 'ASSIGNED'
  total_assigned_bugs_count = bugzilla_helpers.get_count_of_multiple_bugs_by_ids(blockedId, status);

  status = 'REOPENED'
  total_reopened_bugs_count = bugzilla_helpers.get_count_of_multiple_bugs_by_ids(blockedId, status);

  status = 'RESOLVED'
  total_resolved_bugs_count = bugzilla_helpers.get_count_of_multiple_bugs_by_ids(blockedId, status);

  send_event('bgz_audio_video_total_bugs_count', { current: total_bugs_count})
  send_event('bgz_audio_video_new_bugs_count', { current: total_new_bugs_count})
  send_event('bgz_audio_video_assigned_bugs_count', { current: total_assigned_bugs_count})
  send_event('bgz_audio_video_reopened_bugs_count', { current: total_reopened_bugs_count})
  send_event('bgz_audio_video_resolved_bugs_count', { current: total_resolved_bugs_count})

end