module Opayo
  class Error < StandardError
  end

  class RequestError < Error
    def initialize(http_response)
      super(http_response)
    end
  end
end
