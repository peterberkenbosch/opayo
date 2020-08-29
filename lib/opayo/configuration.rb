require "base64"

module Opayo
  class Configuration
    attr_accessor :integration_key
    attr_accessor :integration_password
    attr_accessor :vendor_name
    attr_accessor :environment

    ENDPOINTS = {
      test: "pi-test.sagepay.com",
      live: "pi-live.sagepay.com"
    }

    def initialize
      @environment = :test
    end

    def endpoint
      "https://#{ENDPOINTS[environment]}"
    end
  end

  class << self
    def config
      @configuration ||= Configuration.new
    end

    attr_writer :configuration

    def configure
      yield config
    end
  end
end
