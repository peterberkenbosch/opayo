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

        response = subject.http_call(:get, :method, Opayo::Struct::Base)
        expect(stub).to have_been_requested
        expect(response).to be_success
        expect(response.http_code).to eql 200
        expect(response.payload).to be_a(Opayo::Struct::Base)
      end
    end

    describe "using another http method then :post or :get" do
      it "will raise a RequestError" do
        expect { subject.http_call(:patch, :foo, Opayo::Struct::Base) }.to raise_error(Opayo::RequestError, "Invalid HTTP Method: PATCH")
      end
    end

    describe "when request times out" do
      it "will raise a RequestError" do
        stub = stub_request(:get, "https://pi-test.sagepay.com/api/v1/method")
          .with(headers: stub_headers)
          .with(basic_auth: stub_basic_auth)
          .to_timeout

        expect { subject.http_call(:get, :method, Opayo::Struct::Base) }.to raise_error(Opayo::RequestError, "execution expired")
        expect(stub).to have_been_requested
      end
    end

    describe "when we get a 500" do
      it "will return response that is not succesful" do
        stub = stub_request(:get, "https://pi-test.sagepay.com/api/v1/method")
          .with(headers: stub_headers)
          .with(basic_auth: stub_basic_auth)
          .to_return(status: 500, body: "{}", headers: {})

        response = subject.http_call(:get, :method, Opayo::Struct::Base)
        expect(stub).to have_been_requested
        expect(response).not_to be_success
        expect(response.http_code).to eql 500
      end
    end
  end
end
