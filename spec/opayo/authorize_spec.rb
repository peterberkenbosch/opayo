require "spec_helper"

RSpec.describe Opayo::Client, ".authorize" do
  let(:payload) { read_json_fixture("create_deferred_transaction.json") }
  let(:merchant_session_key) { "7BACF889-B656-4DA4-83AF-637361D64928" }
  let(:card_identifier) { "6DCF9907-87E0-4728-86AE-292CF77FB026" }

  before do # TODO figure out why this is needed when running the full suite, spec_helper before config does not works?
    Opayo.configure do |config|
      config.integration_key = "hJYxsw7HLbj40cB8udES8CDRFLhuJ8G54O6rDpUXvE6hYDrria"
      config.integration_password = "o2iHSrFybYMZpmWOQMuhsXP52V4fBtpuSDshrKDSWsBY1OiN6hwd9Kb12z4j5Us5u"
      config.vendor_name = "sandbox"
      config.environment = :test
    end
  end

  context "with valid merchant key and card identifier" do
    it "will return a Response with the transaction" do
      stub = stub_request(:post, "https://pi-test.sagepay.com/api/v1/transactions")
        .with(basic_auth: stub_basic_auth)
        .with(body: payload.to_json)
        .to_return(read_http_fixture("create_transaction/success.http"))

      response = Opayo::Client.new.authorize(merchant_session_key, card_identifier, payload)
      expect(response).to be_success
      expect(response.payload).to be_a(Opayo::Struct::Transaction)
      expect(stub).to have_been_requested
    end
  end

  context "with invalid merchant key and/or card identifier" do
    it "will return a failed Response" do
      stub = stub_request(:post, "https://pi-test.sagepay.com/api/v1/transactions")
        .with(basic_auth: stub_basic_auth)
        .with(body: payload.to_json)
        .to_return(read_http_fixture("create_transaction/invalid.http"))

      response = Opayo::Client.new.authorize(merchant_session_key, card_identifier, payload)
      expect(response).not_to be_success
      expect(response.payload).to be_a(Opayo::Struct::Error)
      expect(response.payload.description).to eql "Merchant session key or card identifier invalid"
      expect(response.payload.code).to eql 1011
      expect(stub).to have_been_requested
    end
  end
end
