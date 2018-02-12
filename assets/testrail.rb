#
# TestRail API binding for Ruby (API v2, available since TestRail 3.0)
#
# Learn more:
#
# http://docs.gurock.com/testrail-api2/start
# http://docs.gurock.com/testrail-api2/accessing
#
# Copyright Gurock Software GmbH. See license.md for details.
#

require 'net/http'
require 'net/https'
require 'uri'
require 'json'

module TestRail
	class Helpers
		@client = nil
		def initialize(client)
			@client = client
		end

		# when you need test plan stats for an entire project
		def get_plan_stats_for_project(project_id)
			failure_count = 0
			regression_count = 0
			plans = @client.send_get('get_plans/%s' % project_id)
		  total_plans = plans.size
		  for plan in plans
		    if plan["is_completed"]
		      failure_count += plan["failed_count"]
		      regression_count += plan["retest_count"]
		    end
		    plan_date = Time.at(plan["created_on"]).to_datetime
		  end

		  if failure_count > 0 and total_plans > 0
			  failures_per_run = ( failure_count.to_f / total_plans.to_f ).round(2)
			else
			  failures_per_run = 0
			end

			if regression_count > 0 and total_plans > 0
			  regressions_per_run = ( regression_count.to_f / total_plans.to_f ).round(2)
			else
			  regressions_per_run = 0
			end

			failures_last_30_days = 0
			regressions_last_30_days = 0
		  return [failures_per_run, failures_last_30_days, failure_count, regressions_per_run, regressions_last_30_days, regression_count]
		end

		# when you need test plan stats for a specific suite within a project
		def get_plan_stats_for_project_by_suite(project_id, suite_id)
			failure_count = 0
			regression_count = 0
		  total_runs = 0
			plans = @client.send_get('get_plans/%s' % project_id)
		  for plan in plans
		  	plan_details = @client.send_get('get_plan/%s' % plan["id"])
		  	for run_entry in plan_details["entries"]
		  		if run_entry["suite_id"] == suite_id
		  			total_runs += run_entry["runs"].size
		  			for run in run_entry["runs"]
					    if run["is_completed"] and project_id == run["project_id"] and suite_id == run["suite_id"]
					      failure_count += run["failed_count"]
					      regression_count += run["retest_count"]
					    end
					    run_date = Time.at(run["created_on"]).to_datetime
					  end
					end
				end
		  end

		  if failure_count > 0 and total_runs > 0
			  failures_per_run = ( failure_count.to_f / total_runs.to_f ).round(2)
			else
			  failures_per_run = 0
			end

			if regression_count > 0 and total_runs > 0
			  regressions_per_run = ( regression_count.to_f / total_runs.to_f ).round(2)
			else
			  regressions_per_run = 0
			end

			failures_last_30_days = 0
			regressions_last_30_days = 0
		  return [failures_per_run, failures_last_30_days, failure_count, regressions_per_run, regressions_last_30_days, regression_count]
		end

		def get_suite_stats_for_project(project_id)
			total_cases_count = 0
			total_cases_by_day = []
			automation_complete_count = 0
			automatable_count = 0
			suites = @client.send_get('get_suites/%s' % project_id)
		  for suite in suites
		    suite_id = suite["id"]
		    cases = @client.send_get("get_cases/#{project_id}&suite_id=#{suite_id}")
		    for testcase in cases
		      total_cases_count += 1
		      testcase_date = testcase["created_on"] % (60*60*24)
		      if total_cases_by_day.empty?
		        total_cases_by_day << { x: testcase_date, y: 1}
		      else
		        matching_date = total_cases_by_day.find {|item| item[:x] == testcase_date }
		        if not matching_date
		          total_cases_by_day << { x: testcase_date, y: 1}
		        else
		          matching_date[:y] = matching_date[:y] + 1
		        end
		      end
		      if testcase['custom_automatable'] == true
		        automatable_count += 1
		      end
		      if testcase["type_id"] == 3
		        automation_complete_count += 1
		      end
		    end
		  end

		  if automatable_count > 0 and total_cases_count > 0
		    possible_automation_pct = ( automatable_count.to_f / total_cases_count.to_f ) * 100
		  else
		    possible_automation_pct = 0
		  end

		  if automation_complete_count > 0 and automatable_count > 0
		    automation_coverage_pct = ( automation_complete_count.to_f / automatable_count.to_f ) * 100
		  else
		    automation_coverage_pct = 0
		  end
		  return [total_cases_count, possible_automation_pct, automation_coverage_pct]
		end

		def get_suite_stats_for_project_by_suite(project_id, suite_id)
			total_cases_count = 0
			total_cases_by_day = []
			automation_complete_count = 0
			automatable_count = 0
			suites = @client.send_get('get_suites/%s' % project_id)
		  for suite in suites
		    if suite["id"] == suite_id
			    cases = @client.send_get("get_cases/#{project_id}&suite_id=#{suite_id}")
			    for testcase in cases
			      total_cases_count += 1
			      testcase_date = testcase["created_on"] % (60*60*24)
			      if total_cases_by_day.empty?
			        total_cases_by_day << { x: testcase_date, y: 1}
			      else
			        matching_date = total_cases_by_day.find {|item| item[:x] == testcase_date }
			        if not matching_date
			          total_cases_by_day << { x: testcase_date, y: 1}
			        else
			          matching_date[:y] = matching_date[:y] + 1
			        end
			      end
			      if testcase['custom_automatable'] == true
			        automatable_count += 1
			      end
			      if testcase["type_id"] == 3
			        automation_complete_count += 1
			      end
			    end
			  end
		  end

		  if automatable_count > 0 and total_cases_count > 0
		    possible_automation_pct = ( automatable_count.to_f / total_cases_count.to_f ) * 100
		  else
		    possible_automation_pct = 0
		  end

		  if automation_complete_count > 0 and automatable_count > 0
		    automation_coverage_pct = ( automation_complete_count.to_f / automatable_count.to_f ) * 100
		  else
		    automation_coverage_pct = 0
		  end
		  return [total_cases_count, possible_automation_pct, automation_coverage_pct]
		end



		def get_suite_stats(suite_id)
			suite = @client.send_get('get_suite/%s' % suite_id)
			test_cases = @client.send_get("get_cases/#{suite['project_id']}&suite_id=#{suite_id}")

			total_cases_count = test_cases.size
			untriaged_cases = 0
			suitable_cases = 0
			unsuitable_cases = 0
			completed_cases = 0

			for case_ in test_cases
				case case_['custom_automation_status']
					when 1
						untriaged_cases+=1
					when 2
						suitable_cases+=1
					when 3
						unsuitable_cases+=1
					when 4
						completed_cases+=1
				end
			end


			return [total_cases_count, untriaged_cases, suitable_cases, unsuitable_cases, completed_cases]

		end

	end

	class APIClient
		@url = ''
		@user = ''
		@password = ''

		attr_accessor :user
		attr_accessor :password

		def initialize(base_url)
			if !base_url.match(/\/$/)
				base_url += '/'
			end
			@url = base_url + 'index.php?/api/v2/'
		end

		#
		# Send Get
		#
		# Issues a GET request (read) against the API and returns the result
		# (as Ruby hash).
		#
		# Arguments:
		#
		# uri                 The API method to call including parameters
		#                     (e.g. get_case/1)
		#
		def send_get(uri)
			_send_request('GET', uri, nil)
		end

		#
		# Send POST
		#
		# Issues a POST request (write) against the API and returns the result
		# (as Ruby hash).
		#
		# Arguments:
		#
		# uri                 The API method to call including parameters
		#                     (e.g. add_case/1)
		# data                The data to submit as part of the request (as
		#                     Ruby hash, strings must be UTF-8 encoded)
		#
		def send_post(uri, data)
			_send_request('POST', uri, data)
		end

		private
		def _send_request(method, uri, data)
			url = URI.parse(@url + uri)
			if method == 'POST'
				request = Net::HTTP::Post.new(url.path + '?' + url.query)
				request.body = JSON.dump(data)
			else
				request = Net::HTTP::Get.new(url.path + '?' + url.query)
			end
			request.basic_auth(@user, @password)
			request.add_field('Content-Type', 'application/json')

			conn = Net::HTTP.new(url.host, url.port)
			if url.scheme == 'https'
				conn.use_ssl = true
				conn.verify_mode = OpenSSL::SSL::VERIFY_NONE
			end
			response = conn.request(request)

			if response.body && !response.body.empty?
				result = JSON.parse(response.body)
			else
				result = {}
			end

			if response.code != '200'
				if result && result.key?('error')
					error = '"' + result['error'] + '"'
				else
					error = 'No additional error message received'
				end
				raise APIError.new('TestRail API returned HTTP %s (%s)' %
					[response.code, error])
			end

			result
		end
	end

	class APIError < StandardError
	end
end
