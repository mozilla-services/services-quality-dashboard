require 'rest-client'
require 'json'
require 'date'
require 'open-uri'
require 'nokogiri'
require 'pp'

require_relative '../assets/testrail'

SCHEDULER.every '60m', :first_in => 0 do |job|

  project_list_source = open("https://wiki.mozilla.org/TestEngineering#Full_Project_List").read()

  capture_html = Nokogiri::HTML(project_list_source)

  rows = capture_html.xpath("//table/tr")

  details = rows.collect do |row|
    detail = {}
    [
      [:project, 'td[1]/text()'],
      [:primary, 'td[2]/text()'],
      [:secondary, 'td[3]/text()'],
      [:irc_channel, 'td[4]/text()'],
      [:group, 'td[5]/text()'],
      [:test_suite, 'td[6]/@style'],
      [:unit_tests, 'td[7]/@style'],
      [:functional_tests, 'td[8]/@style'],
      [:load_tests, 'td[9]/@style'],
      [:performance_tests, 'td[10]/@style'],
      [:accessibility_tests, 'td[11]/@style'],
      [:security_tests, 'td[12]/@style'],
      [:localization_tests, 'td[13]/@style'],
      [:swagger_def, 'td[14]/text()'],
    ].each do |name, xpath|
      detail[name] = row.at_xpath(xpath).to_s.strip
    end
    detail
  end

  test_suites_complete = 0
  unit_tests_complete = 0
  functional_tests_complete = 0
  load_tests_complete = 0
  performance_tests_complete = 0
  accessibility_tests_complete = 0
  security_tests_complete = 0
  localization_tests_complete = 0

  grouped_by_test_suite = details.group_by {|item| item[:test_suite]}
  if grouped_by_test_suite.any? {|k,v| k.include? "lightgreen"} then
    test_suites_complete = grouped_by_test_suite["background:lightgreen;text-align:center;"].length
    test_suites_complete_pct = ((test_suites_complete.to_f / details.length.to_f) * 100).round(2)
  end

  grouped_by_unit_tests = details.group_by {|item| item[:unit_tests]}
  if grouped_by_unit_tests.any? {|k,v| k.include? "lightgreen"} then
    unit_tests_complete = grouped_by_unit_tests["background:lightgreen;text-align:center;"].length
    unit_tests_complete_pct = (unit_tests_complete.to_f / details.length.to_f).round(2)
  end

  grouped_by_functional_tests = details.group_by {|item| item[:functional_tests]}
  if grouped_by_functional_tests.any? {|k,v| k.include? "lightgreen"} then
    functional_tests_complete = grouped_by_functional_tests["background:lightgreen;text-align:center;"].length
    functional_tests_complete_pct = (functional_tests_complete.to_f / details.length.to_f).round(2)
  end

  grouped_by_load_tests = details.group_by {|item| item[:load_tests]}
  if grouped_by_load_tests.any? {|k,v| k.include? "lightgreen"} then
    load_tests_complete = grouped_by_load_tests["background:lightgreen;text-align:center;"].length
    load_tests_complete_pct = (load_tests_complete.to_f / details.length.to_f).round(2)
  end

  grouped_by_performance_tests = details.group_by {|item| item[:performance_tests]}
  if grouped_by_performance_tests.any? {|k,v| k.include? "lightgreen"} then
    performance_tests_complete = grouped_by_performance_tests["background:lightgreen;text-align:center;"].length
    performance_tests_complete_pct = (performance_tests_complete.to_f / details.length.to_f).round(2)
  end

  grouped_by_accessibility_tests = details.group_by {|item| item[:accessibility_tests]}
  if grouped_by_accessibility_tests.any? {|k,v| k.include? "lightgreen"} then
    accessibility_tests_complete = grouped_by_accessibility_tests["background:lightgreen;text-align:center;"].length
    accessibility_tests_complete_pct = (accessibility_tests_complete.to_f / details.length.to_f).round(2)
  end

  grouped_by_security_tests = details.group_by {|item| item[:security_tests]}
  if grouped_by_security_tests.any? {|k,v| k.include? "lightgreen"} then
    security_tests_complete = grouped_by_security_tests["background:lightgreen;text-align:center;"].length
    security_tests_complete_pct = (security_tests_complete.to_f / details.length.to_f).round(2)
  end

  grouped_by_localization_tests = details.group_by {|item| item[:localization_tests]}
  if grouped_by_localization_tests.any? {|k,v| k.include? "lightgreen"} then
    localization_tests_complete = grouped_by_localization_tests["background:lightgreen;text-align:center;"].length
    localization_tests_complete_pct = (localization_tests_complete.to_f / details.length.to_f).round(2)
  end

  total_automation_possibilities = details.length * 7 #7 being the number of test automation types
  total_automation_complete = unit_tests_complete + functional_tests_complete + load_tests_complete +
    performance_tests_complete + accessibility_tests_complete + security_tests_complete + localization_tests_complete
  total_automation_complete_pct = (total_automation_complete.to_f / total_automation_possibilities.to_f * 100).round(2)

  send_event('2017_okr_test_suites_complete', { value: test_suites_complete_pct})
  send_event('2017_okr_test_automation_complete', { value: total_automation_complete_pct})
end
