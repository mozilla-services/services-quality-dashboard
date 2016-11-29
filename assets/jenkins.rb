#
# Jenkins API Helpers
#
# Learn more:
#
# https://wiki.jenkins-ci.org/display/JENKINS/Remote+access+API
#

require 'rest-client'
require 'net/http'
require 'net/https'
require 'uri'
require 'json'

module Jenkins
	class Helpers

		@jenkins_url = nil
		@test_repos = nil

		def initialize(jenkins_url="")
			if jenkins_url.empty?
				jenkins_url = "https://fx-test-jenkins-dev.stage.mozaws.net:8443/"
			end
			@jenkins_url = jenkins_url
			@test_repos = [
				"https://github.com/mozilla-services/services-test/",
				"https://github.com/rpappalax/jenkins-job-manager/"
			]
		end

		def get_all_jobs()
			url = "#{@jenkins_url}/api/json?tree=jobs[name]"
			response = RestClient::Request.execute(method: :get, url: url, verify_ssl: false)
			job_list = JSON.parse(response)
			return job_list
		end

		def get_project_github_url(project_name)
			url = "#{@jenkins_url}/job/#{project_name}/api/json?&depth=3&tree=scm[userRemoteConfigs[url]]"
			response = RestClient::Request.execute(method: :get, url: url, verify_ssl: false)
			project_scm = JSON.parse(response)
		  return project_scm
		end

		def is_github_url_dev_repo(github_url)
			if @test_repos.include? github_url
				return false
			end
			return true
		end

	end
end
