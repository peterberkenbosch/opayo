require "spec_helper"
require "base64"

RSpec.describe Opayo::Configuration do
  after { restore_config }

  context "when environment is not specified" do
    before do
      Opayo.configure {}
    end

    it "defaults to test" do
      expect(Opayo.config.environment).to eq(:test)
    end

    it "sets the endpoint to the test uri" do
      expect(Opayo.config.endpoint).to eq("https://pi-test.sagepay.com")
    end
  end

  context "when environment is set to live" do
    before do
      Opayo.configure do |config|
        config.environment = :live
      end
    end

    it "returns the live environment" do
      expect(Opayo.config.environment).to eq(:live)
    end

    it "sets endpoint to the live uri" do
      expect(Opayo.config.endpoint).to eq("https://pi-live.sagepay.com")
    end
  end

  context "configure" do
    before do
      Opayo.configure do |config|
        config.integration_key = "abc"
        config.integration_password = "xyz"
        config.vendor_name = "pbctest"
        config.environment = :test
      end
    end

    it "has an integration_key" do
      expect(Opayo.config.integration_key).to eq("abc")
    end

    it "has an integration_password" do
      expect(Opayo.config.integration_password).to eq("xyz")
    end

    it "has a vendor_name" do
      expect(Opayo.config.vendor_name).to eq("pbctest")
    end
  end

  private

  def restore_config
    Opayo.configuration = nil
    Opayo.configure {}
  end
end
