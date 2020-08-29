require "spec_helper"

RSpec.describe Opayo::Client do
  subject { Opayo::Client.new }

  describe "user_agent_string" do
    it "has this gem version, with ruby and OpenSSL version" do
      expect(subject.user_agent_string).to match(/^Opayo\/#{Opayo::VERSION} Ruby\/#{RUBY_VERSION} OpenSSL\/.*$/)
    end
  end

  describe "http_call" do
    context ":get with default params" do
      it "will build a proper request" do
        stub = stub_request(:get, "https://pi-test.sagepay.com/api/v1/method")
          .with(headers: stub_headers)
          .with(basic_auth: stub_basic_auth)
          .to_return(status: 200, body: "{}", headers: {})

        subject.http_call(:get, :method)
        expect(stub).to have_been_requested
      end
    end
  end
end
