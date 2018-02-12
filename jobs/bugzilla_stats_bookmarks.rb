require 'rest-client'

require_relative '../assets/bugzilla'



SCHEDULER.every '60m', :first_in => 0 do |job|

  url = 'https://bugzilla.mozilla.org/'
  client = BugZilla::APIClient.new(url)
  client.user = ENV['BUGZILLA_USERNAME']
  client.password = ENV['BUGZILLA_PASSWORD']
  bugzilla_helpers = BugZilla::Helpers.new(client)


  #Bug 1419383 - [meta] Add automated tests for Bookmarks functionality
  blockedId = '1419383'

  status = nil
  total_bugs_count = bugzilla_helpers.get_count_of_blocked_bugs_by_status(blockedId, status);

  status = 'NEW'
  total_new_bugs_count = bugzilla_helpers.get_count_of_blocked_bugs_by_status(blockedId, status);

  status = 'ASSIGNED'
  total_assigned_bugs_count = bugzilla_helpers.get_count_of_blocked_bugs_by_status(blockedId, status);

  status = 'REOPENED'
  total_reopened_bugs_count = bugzilla_helpers.get_count_of_blocked_bugs_by_status(blockedId, status);

  status = 'RESOLVED'
  total_resolved_bugs_count = bugzilla_helpers.get_count_of_blocked_bugs_by_status(blockedId, status);

  send_event('bgz_bookmarks_total_bugs_count', { current: total_bugs_count})
  send_event('bgz_bookmarks_new_bugs_count', { current: total_new_bugs_count})
  send_event('bgz_bookmarks_assigned_bugs_count', { current: total_assigned_bugs_count})
  send_event('bgz_bookmarks_reopened_bugs_count', { current: total_reopened_bugs_count})
  send_event('bgz_bookmarks_resolved_bugs_count', { current: total_resolved_bugs_count})

end