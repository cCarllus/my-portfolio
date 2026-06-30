require "rails_helper"

RSpec.describe Admin::Credentials do
  around do |example|
    original = ENV.to_h.slice("ADMIN_EMAIL", "ADMIN_PASSWORD", "ADMIN_TRIGGER_EMAIL")
    ENV.update(
      "ADMIN_EMAIL" => "crick.lucas@gmail.com",
      "ADMIN_PASSWORD" => "strong-password",
      "ADMIN_TRIGGER_EMAIL" => "crick.lucas@gmail.com"
    )
    example.run
  ensure
    %w[ADMIN_EMAIL ADMIN_PASSWORD ADMIN_TRIGGER_EMAIL].each { |key| ENV.delete(key) }
    ENV.update(original)
  end

  it "authenticates only the configured credentials" do
    expect(described_class.valid?("crick.lucas@gmail.com", "strong-password")).to be(true)
    expect(described_class.valid?("crick.lucas@gmail.com", "wrong")).to be(false)
  end

  it "recognizes the configured easter egg address case-insensitively" do
    expect(described_class.trigger_email?(" CRICK.LUCAS@GMAIL.COM ")).to be(true)
    expect(described_class.trigger_email?("visitor@example.com")).to be(false)
  end
end
