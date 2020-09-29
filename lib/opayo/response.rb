module Opayo
  class Response
    attr_reader :success, :payload, :error, :http_code

    def initialize(http_response, payload_struct_class)
      http_code = http_response.code.to_i
      @http_code = http_code
      case http_code
      when 200, 201
        @success = true
        @payload = build_payload(JSON.parse(http_response.body), payload_struct_class)
      else
        @success = false
        @error = http_response
        @payload = build_payload(JSON.parse(http_response.body), Opayo::Struct::Error)
      end
    end

    def success?
      @success
    end

    private

    def build_payload(json_body, payload_struct_class)
      payload_struct_class.new(json_body)
    end
  end
end
