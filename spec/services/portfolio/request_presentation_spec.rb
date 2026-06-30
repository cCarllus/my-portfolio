require "rails_helper"

RSpec.describe Portfolio::RequestPresentation do
  include ActiveJob::TestHelper

  before { create_portfolio_profile }

  it "persists the request and enqueues delivery" do
    expect do
      described_class.call(
        email: "visitor@example.com",
        locale: :pt,
        request_ip: "127.0.0.1",
        user_agent: "RSpec"
      )
    end.to have_enqueued_job(SendPortfolioPresentationJob)

    request = ContactRequest.last
    expect(request).to have_attributes(email: "visitor@example.com", status: "pending")
  end
end
