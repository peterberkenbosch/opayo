module HttpResponses
  def stub_headers
    {
      "Accept" => "application/json",
      "Content-type" => "application/json",
      "User-Agent" => /^Opayo\/#{Opayo::VERSION} Ruby\/#{RUBY_VERSION} OpenSSL\/.*$/
    }
  end

  def stub_basic_auth
    [
      Opayo.config.integration_key,
      Opayo.config.integration_password
    ]
  end

  def read_http_fixture(name)
    File.read(File.join(File.dirname(__FILE__), "fixtures.http", name))
  end

  def read_json_fixture(name)
    JSON.parse(File.read(File.join(File.dirname(__FILE__), "fixtures.json", name)))
  end
end

RSpec.configure do |config|
  config.include HttpResponses
end
