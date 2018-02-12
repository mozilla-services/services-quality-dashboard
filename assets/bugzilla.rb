#
# Bugzilla API binding for Ruby (API v1)
#
# Learn more:
#
# http://bugzilla.readthedocs.io/en/latest/
# http://bugzilla.readthedocs.io/en/latest/api/core/v1/index.html
#

require 'net/http'
require 'net/https'
require 'uri'
require 'json'



module BugZilla
  class Helpers
    @client = nil
    def initialize(client)
      @client = client
    end


    # when you need bugs stats for blocked bugs in a certain state
    # /rest/bug?blocks=11455741&status=NEW
    def get_count_of_blocked_bugs_by_status(id, status)

      query = "?blocks=#{id}"
      if status != nil?
        query += "&status=#{status}";
      end

      bugs = @client.send_get(query);
      total_bugs = bugs['bugs'].size
    return total_bugs
    end


    # when you need bugs stats for more than one bug
    # eg: /rest/bug?id=12434,43421&status=CLOSED
    def get_count_of_multiple_bugs_by_ids(ids, status)

      query = "?id=#{ids}"
      if status != nil?
        query += "&status=#{status}";
      end

      bugs = @client.send_get(query);
      total_bugs = bugs['bugs'].size
      return total_bugs
    end


  end

  class APIClient
    @url = ''
    @user = ''
    @password = ''

    attr_accessor :user
    attr_accessor :password

    def initialize(base_url)
      @url = base_url + 'rest/bug'
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
        raise APIError.new('Bugzilla API returned HTTP %s (%s)' %
                               [response.code, error])
      end

      result
    end
  end

  class APIError < StandardError
  end
end
