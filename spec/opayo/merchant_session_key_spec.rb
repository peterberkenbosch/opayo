require "spec_helper"

RSpec.describe Opayo::Client, ".merchant_session_key" do
  let(:payload) { read_json_fixture("merchant_session_key.json") }

  before do # TODO figure out why this is needed when running the full suite, spec_helper before config does not works?
    Opayo.configure do |config|
      config.integration_key = "hJYxsw7HLbj40cB8udES8CDRFLhuJ8G54O6rDpUXvE6hYDrria"
      config.integration_password = "o2iHSrFybYMZpmWOQMuhsXP52V4fBtpuSDshrKDSWsBY1OiN6hwd9Kb12z4j5Us5u"
      config.vendor_name = "sandbox"
      config.environment = :test
    end
  end

  context "with valid credentials" do
    it "will return a Response with the merchant session key" do
      stub = stub_request(:post, "https://pi-test.sagepay.com/api/v1/merchant-session-keys")
        .with(headers: stub_headers)
        .with(basic_auth: stub_basic_auth)
        .with(body: payload.to_json)
        .to_return(read_http_fixture("merchant_session_key/success.http"))

      response = Opayo::Client.new.merchant_session_key
      expect(response).to be_success
      expect(response.payload).to be_a(Opayo::Struct::MerchantSessionKey)
      expect(response.payload.merchantSessionKey).to eql "80AA3065-E94B-4E72-ACDA-26E8511FA8C8"
      expect(stub).to have_been_requested
    end
  end
end
