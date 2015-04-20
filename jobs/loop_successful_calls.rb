require "rubygems"
require 'rest-client'
require 'json'
require 'net/http'

SCHEDULER.every '10s', :first_in => 0 do |job|
  # url = 'http://metrics.services.mozilla.com/loop-server-dashboard/data/loop_daily_call_stats.json'
  # response = RestClient.get(url)
  # puts response
  # response = RestClient::Request.new(
  #   :method => :get,
  #   :url => url,
  #   :user => @user,
  #   :password => @pass,
  #   :headers => { :accept => :json,
  #   :content_type => :json }
  # ).execute

  # data = JSON.parse(response)
  # points = []
  # max_calls = 0
  # for day in data["daily_call_stats"]
  #   success_calls = day["unique_success"]
  #   total_calls = day["unique_callid"]
  #   date = day["date"]
  #   success_percent = success_calls.to_f / total_calls.to_f
  #   # max_calls = total_calls if total_calls > max_calls
  #   points << {:x => date, :y => success_percent}
  # end
  # send_event('loop_call_success', points: points, displayedValue: points.last["y"])
end
