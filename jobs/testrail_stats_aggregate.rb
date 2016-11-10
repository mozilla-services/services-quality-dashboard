# require 'rest-client'
# require 'json'
# require 'date'

# require_relative '../assets/testrail'

# total_cases_by_day = []
# total_cases_count = 0
# automation_coverage_pct = 0
# automatable_count = 0

# SCHEDULER.every '60m', :first_in => 0 do |job|

#   automation_complete_count = 0
#   last_automation_coverage_pct = automation_coverage_pct
#   last_total_cases_count = total_cases_count
#   last_automatable_count = automatable_count

#   url = 'https://testrail.stage.mozaws.net/'
#   client = TestRail::APIClient.new(url)
#   client.user = ENV['TESTRAIL_USERNAME']
#   client.password = ENV['TESTRAIL_PASSWORD']

#   puts "Collecting testrail stats..."

#   # puts "get_case_types"
#   # case_types = client.send_get('get_case_types')
#   # puts case_types

#   projects = client.send_get('get_projects')
#   # projects sample output
#   # {
#   #   "id"=>3,
#   #   "name"=>"Test Pilot",
#   #   "announcement"=>nil,
#   #   "show_announcement"=>false,
#   #   "is_completed"=>false,
#   #   "completed_on"=>nil,
#   #   "suite_mode"=>3,
#   #   "url"=>"https://testrail.stage.mozaws.net/index.php?/projects/overview/3"
#   # }
#   for project in projects

#     project_id = project["id"]
#     if project["suite_mode"] == 1 #single-suite project
#       # cases = client.send_get('get_cases/%s' % project_id)
#       # cases_to_add = {case["id"]: case for case in cases if case[filter_key] is True}

#       # if len(cases_to_add) > 0:
#       #   one_and_done_cases["projects"][project_id] = {}
#       #   one_and_done_cases["projects"][project_id]["project_name"] = project["name"]
#       #   one_and_done_cases["projects"][project_id]["cases"] = cases_to_add
#     end
#     if project["suite_mode"] == 3 # multi-suite project
#       suites = client.send_get('get_suites/%s' % project_id)
#       #suites sample output
#       # {
#       #   "id"=>224,
#       #   "name"=>"Validation",
#       #   "description"=>nil,
#       #   "project_id"=>24,
#       #   "is_master"=>false,
#       #   "is_baseline"=>false,
#       #   "is_completed"=>false,
#       #   "completed_on"=>nil,
#       #   "url"=>"https://testrail.stage.mozaws.net/index.php?/suites/view/224"
#       # }

#       for suite in suites
#         suite_id = suite["id"]
#         cases = client.send_get("get_cases/#{project_id}&suite_id=#{suite_id}")
#         # sample case output
#         # {
#         #   "id"=>7133,
#         #   "title"=>"Account test - Create a new account",
#         #   "section_id"=>641,
#         #   "template_id"=>1,
#         #   "type_id"=>7,
#         #   "priority_id"=>2,
#         #   "milestone_id"=>nil,
#         #   "refs"=>nil,
#         #   "created_by"=>14,
#         #   "created_on"=>1475176273,
#         #   "updated_by"=>63,
#         #   "updated_on"=>1476991219,
#         #   "estimate"=>nil,
#         #   "estimate_forecast"=>nil,
#         #   "suite_id"=>224,
#         #   "custom_test_case_owner"=>13,
#         #   "custom_automatable"=>true,
#         #   "custom_preconds"=>"The ability to access:\r\n* https://developer.allizom.org\r\n* http://personatestuser.org/email",
#         #   "custom_steps"=>"Steps\r\n1. Using a browser, navigate to http://personatestuser.org/email and save the email and password for later use.\r\n2. Using a browser, navigate to https://developer.allizom.org. Login using Persona.\r\n3. Use the credentials you acquired from personatestuser to login to MDN https://developer.allizom.org\r\n4. Navigate to Profile Edit and edit the test accounts profile\r\n5. Logout after editing the profile\r\n6. Login to the test account again and view the test account's profile\r\n",
#         #   "custom_expected"=>"* Verify the ability to create a new account works as expected.\r\n* Verify the ability edit the test account's profile works as expected.\r\n* After logging out and then back into verify the changes to the test account's profile persisted.",
#         #   "custom_steps_separated"=>nil,
#         #   "custom_mission"=>nil,
#         #   "custom_goals"=>nil
#         # }
#         for testcase in cases
#           total_cases_count += 1
#           testcase_date = testcase["created_on"] % (60*60*24)
#           if total_cases_by_day.empty?
#             total_cases_by_day << { x: testcase_date, y: 1}
#           else
#             matching_date = total_cases_by_day.find {|item| item[:x] == testcase_date }
#             if not matching_date
#               total_cases_by_day << { x: testcase_date, y: 1}
#             else
#               matching_date[:y] = matching_date[:y] + 1
#             end
#           end
#           if testcase['custom_automatable'] == true
#             automatable_count += 1
#           end
#           if testcase["type_id"] == 3
#             automation_complete_count += 1
#           end
#         end
#       end
#     end
#   end

#   puts "Collection complete. Time for Math!"

#   total_cases_by_day_sorted = total_cases_by_day.sort_by { |item| item[:x] }

#   puts "last 30 days"
#   puts total_cases_by_day_sorted.last(30)
#   puts "last 60 days"
#   puts total_cases_by_day_sorted.last(60)
#   puts "last 90 days"
#   puts total_cases_by_day_sorted.last(90)

#   possible_automation_pct = ( automatable_count.to_f / total_cases_count.to_f ) * 100
#   automation_coverage_pct = ( automation_complete_count.to_f / automatable_count.to_f ) * 100
#   send_event('tr_auto_versus_total', { value: possible_automation_pct})
#   send_event('tr_auto_coverage_total', { value: automation_coverage_pct})
#   # send_event('tr_total_cases_count', { current: total_cases, last: last_total_cases })
#   send_event('tr_total_cases_count_by_day', points: total_cases_by_day_sorted.last(30))
#   send_event('tr_total_cases_count', { current: total_cases_count, last: last_total_cases_count })
#   send_event('tr_total_automatable_count', { current: automatable_count, last: last_automatable_count })
#   # send_event('tr_total_automatable_count', { current: automatable_count, last: last_automatable_count })
# end
