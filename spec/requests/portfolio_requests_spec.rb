require "rails_helper"

RSpec.describe "Portfolio presentation requests", type: :request do
  include ActiveJob::TestHelper

  before do
    create_portfolio_profile
    allow(Admin::Credentials).to receive(:trigger_email?).and_call_original
  end

  it "queues a presentation for a valid public email" do
    expect do
      post portfolio_request_path, params: { contact_request: { email: "visitor@example.com", website: "" } }
    end.to have_enqueued_job(SendPortfolioPresentationJob)

    expect(response).to redirect_to(root_path)
  end

  it "redirects the configured owner email to the hidden login" do
    allow(Admin::Credentials).to receive(:trigger_email?).with("crick.lucas@gmail.com").and_return(true)

    post portfolio_request_path, params: { contact_request: { email: "crick.lucas@gmail.com", website: "" } }

    expect(response).to redirect_to(new_admin_session_path)
    expect(ContactRequest.count).to eq(0)
  end

  it "silently rejects honeypot submissions" do
    post portfolio_request_path, params: { contact_request: { email: "bot@example.com", website: "spam" } }

    expect(response).to redirect_to(root_path)
    expect(ContactRequest.count).to eq(0)
  end
end
