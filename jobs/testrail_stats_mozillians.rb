require 'rest-client'
require 'json'
require 'date'

require_relative '../assets/testrail'

total_cases_by_day = []
total_cases_count = 0
automation_coverage_pct = 0
automatable_count = 0
total_plans = 0
failure_count = 0
failures_per_run = 0
regression_count = 0
regressions_per_run = 0

SCHEDULER.every '60m', :first_in => 0 do |job|

  automation_complete_count = 0
  last_automation_coverage_pct = automation_coverage_pct
  last_total_cases_count = total_cases_count
  last_automatable_count = automatable_count
  last_failures_per_run = failures_per_run
  last_failure_count = failure_count
  last_regression_count = regression_count
  last_regressions_per_run = regressions_per_run

  url = 'https://testrail.stage.mozaws.net/'
  client = TestRail::APIClient.new(url)
  client.user = ENV['TESTRAIL_USERNAME']
  client.password = ENV['TESTRAIL_PASSWORD']
  testrail_helpers = TestRail::Helpers.new(client)

  # Mozillians is project #43
  # https://testrail.stage.mozaws.net/index.php?/projects/overview/43
  project_id = 43

  total_cases_count,
  possible_automation_pct,
  automation_coverage_pct = testrail_helpers.get_suite_stats_for_project(project_id)

  failures_per_run,
  failures_last_30_days,
  failure_count,
  regressions_per_run,
  regressions_last_30_days,
  regression_count = testrail_helpers.get_plan_stats_for_project(project_id)

  send_event('tr_mozillians_auto_versus_total', { value: possible_automation_pct})
  send_event('tr_mozillians_auto_coverage_total', { value: automation_coverage_pct})
  send_event('tr_mozillians_defects_last_30_days', points: failures_last_30_days)
  send_event('tr_mozillians_total_cases_count', { current: total_cases_count, last: last_total_cases_count })
  send_event('tr_mozillians_failures_avg_per_run', { current: failures_per_run, last: last_failures_per_run })
  send_event('tr_mozillians_total_failure_count', { current: failure_count, last: last_failure_count })
  send_event('tr_mozillians_regressions_avg_per_run', { current: regressions_per_run, last: last_regressions_per_run })
  send_event('tr_mozillians_total_regression_count', { current: regression_count, last: last_regression_count })

end
