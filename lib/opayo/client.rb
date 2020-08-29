module Opayo
  class Client
    def initialize
      @version_strings = []
      add_version_string "Opayo/" << VERSION
      add_version_string "Ruby/" << RUBY_VERSION
      add_version_string OpenSSL::OPENSSL_VERSION.split(" ").slice(0, 2).join "/"
    end

    def user_agent_string
      @version_strings.join(" ")
    end

    # Executes a request, validates and returns the response.
    #
    # @param  [String] http_method The HTTP method (:get, :post)
    # @param  [String] api_method The api method to call
    # @param  [String] id the optional id to be pasted in
    # @param  [Hash] an optional body to post to the endpoint
    # @return [Hash]
    # @raise  [RequestError]
    # @raise  [NotFoundError]
    # @raise  [AuthenticationFailed]
    def http_call(http_method, api_method, id = nil, body = {})
      version = "v1"

      path = "/api/#{version}/#{api_method}/#{id}".chomp("/")
      api_endpoint = Opayo.config.endpoint
      uri = URI.parse(api_endpoint)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http.set_debug_output($stdout) if ENV["DEBUG"]

      case http_method
      when :get
        request = Net::HTTP::Get.new(path)
      when :post
        body.delete_if { |_k, v| v.nil? }
        request = Net::HTTP::Post.new(path)
        request.body = body.to_json
      else
        raise RequestError, "Invalid HTTP Method: #{http_method.to_s.upcase}"
      end

      request.basic_auth Opayo.config.integration_key, Opayo.config.integration_password

      request["Accept"] = "application/json"
      request["Content-Type"] = "application/json"
      request["User-Agent"] = user_agent_string

      begin
        response = http.request(request)
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
        Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
        raise RequestError, e.message
      end

      http_code = response.code.to_i
      case http_code
      when 200, 201
        JSON.parse(response.body)
      when 400, 403
        # 400 - Bad request
        raise RequestError, response
      when 401
        # 401 - Unauthorized
        raise AuthenticationError, response
      when 404
        # 404 - Not found
        raise NotFoundError, response
      when 500, 502, 503, 504
        # 500, 502, 503, 504 - Server Errors
        raise Error, response
      end
    end

    private

    def add_version_string(version_string)
      @version_strings << version_string.gsub(/\s+/, "-")
    end
  end
end
