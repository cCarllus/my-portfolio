require "rails_helper"

RSpec.describe "Admin authentication", type: :request do
  around do |example|
    original_email = ENV["ADMIN_EMAIL"]
    original_password = ENV["ADMIN_PASSWORD"]
    ENV["ADMIN_EMAIL"] = "admin@example.com"
    ENV["ADMIN_PASSWORD"] = "strong-password"
    example.run
  ensure
    ENV["ADMIN_EMAIL"] = original_email
    ENV["ADMIN_PASSWORD"] = original_password
  end

  it "protects the dashboard" do
    get admin_root_path

    expect(response).to redirect_to(new_admin_session_path)
  end

  it "creates a session with valid environment credentials" do
    post admin_session_path, params: { email: "admin@example.com", password: "strong-password" }

    expect(response).to redirect_to(admin_root_path)
    follow_redirect!
    expect(response.body).to include("Painel administrativo")
  end

  it "rejects invalid credentials" do
    post admin_session_path, params: { email: "admin@example.com", password: "wrong" }

    expect(response).to have_http_status(:unprocessable_content)
  end
end
