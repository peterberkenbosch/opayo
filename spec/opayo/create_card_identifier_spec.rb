require "spec_helper"

RSpec.describe Opayo::Client, ".create_card_identifier" do
  let(:payload) { read_json_fixture("card_identifier.json") }
  let(:merchant_session_key) { "BDD9C0F1-F860-4D02-BF35-2A9FFC1E0A87" }
  let(:headers) { stub_headers.merge("Authorization" => "Bearer #{merchant_session_key}") }

  before do # TODO figure out why this is needed when running the full suite, spec_helper before config does not works?
    Opayo.configure do |config|
      config.integration_key = "hJYxsw7HLbj40cB8udES8CDRFLhuJ8G54O6rDpUXvE6hYDrria"
      config.integration_password = "o2iHSrFybYMZpmWOQMuhsXP52V4fBtpuSDshrKDSWsBY1OiN6hwd9Kb12z4j5Us5u"
      config.vendor_name = "sandbox"
      config.environment = :test
    end
  end

  context "with valid credit card data" do
    it "will return a Response with the card-identifier" do
      stub = stub_request(:post, "https://pi-test.sagepay.com/api/v1/card-identifiers")
        .with(headers: headers)
        .with(body: payload.to_json)
        .to_return(read_http_fixture("create_card_identifier/success.http"))

      response = Opayo::Client.new.create_card_identifier(merchant_session_key, "Bob The Builder", "4929000000006", "0223", "123")
      expect(response).to be_success
      expect(response.payload).to be_a(Opayo::Struct::CardIdentifier)
      expect(response.payload.cardIdentifier).to eql "29D04630-575C-43C3-9FC4-259E86A8D089"
      expect(stub).to have_been_requested
    end
  end

  context "with no valid merchant session key" do
    it "will return an unauthorized response" do
      stub = stub_request(:post, "https://pi-test.sagepay.com/api/v1/card-identifiers")
        .with(headers: headers)
        .with(body: payload.to_json)
        .to_return(read_http_fixture("create_card_identifier/unauthorized.http"))

      response = Opayo::Client.new.create_card_identifier(merchant_session_key, "Bob The Builder", "4929000000006", "0223", "123")
      expect(response).not_to be_success
      expect(response.http_code).to be 401
      expect(response.payload).to be_a(Opayo::Struct::Error)
      expect(response.payload.code).to be 1001
      expect(stub).to have_been_requested
    end
  end
end
