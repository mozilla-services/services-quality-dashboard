require 'rest-client'

require_relative '../assets/bugzilla'



SCHEDULER.every '60m', :first_in => 0 do |job|

  url = 'https://bugzilla.mozilla.org/'
  client = BugZilla::APIClient.new(url)
  client.user = ENV['BUGZILLA_USERNAME']
  client.password = ENV['BUGZILLA_PASSWORD']
  bugzilla_helpers = BugZilla::Helpers.new(client)

  #no meta bug was logged here. One bug is tracking the work
  # Bug 1409885 - Add automated testing for about:webrtc  #
  blockedId = '1409885'

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

  send_event('bgz_webrtc_total_bugs_count', { current: total_bugs_count})
  send_event('bgz_webrtc_new_bugs_count', { current: total_new_bugs_count})
  send_event('bgz_webrtc_assigned_bugs_count', { current: total_assigned_bugs_count})
  send_event('bgz_webrtc_reopened_bugs_count', { current: total_reopened_bugs_count})
  send_event('bgz_webrtc_resolved_bugs_count', { current: total_resolved_bugs_count})

end