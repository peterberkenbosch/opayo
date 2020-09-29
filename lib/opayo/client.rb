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

    # The MSK (merchant session key)
    #
    # The Merchant Session Key expires after 400 seconds and can only be used to create
    # one successful Card Identifier (tokenised card details).
    # It will also expire and be removed after 3 failed attempts to create a Card Identifier.
    #
    # @return <Response> the payload on a succesfull response will <Struct::MerchantSessionKey>
    def merchant_session_key
      http_call(:post, "merchant-session-keys", Opayo::Struct::MerchantSessionKey, nil, {"vendorName" => Opayo.config.vendor_name})
    end

    # Create a card identifier
    #
    # @see https://developer.sage.com/api/payments/api/#operation/createCi
    def create_card_identifier(merchant_session_key, cardholder_name, card_number, expiry_date, security_code)
      payload = {
        "cardDetails" => {
          "cardholderName" => cardholder_name,
          "cardNumber" => card_number,
          "expiryDate" => expiry_date,
          "securityCode" => security_code
        }
      }
      http_call(:post, "card-identifiers", Opayo::Struct::CardIdentifier, nil, payload, merchant_session_key)
    end

    # Executes a request, validates and returns the response.
    #
    # @param  [String] http_method The HTTP method (:get, :post)
    # @param  [String] api_method The api method to call
    # @param  [Class] payload_struct_class The payload struct class for successfull request
    # @param  [String] id the optional id to be pasted in
    # @param  [Hash] body an optional body to post to the endpoint
    # @return [Hash]
    # @raise  [RequestError]
    # @raise  [NotFoundError]
    # @raise  [AuthenticationFailed]
    def http_call(http_method, api_method, payload_struct_class, id = nil, body = {}, merchant_session_key = nil)
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

      request.basic_auth Opayo.config.integration_key, Opayo.config.integration_password unless merchant_session_key
      request["Authentication"] = "Bearer #{merchant_session_key}" if merchant_session_key
      request["Accept"] = "application/json"
      request["Content-Type"] = "application/json"
      request["User-Agent"] = user_agent_string

      begin
        response = http.request(request)
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
        Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
        raise RequestError, e.message
      end

      Response.new(response, payload_struct_class)
    end

    private

    def add_version_string(version_string)
      @version_strings << version_string.gsub(/\s+/, "-")
    end
  end
end
