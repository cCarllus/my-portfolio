require "rails_helper"

RSpec.describe Portfolio::AttachResumeToEmail do
  let(:profile) { create_portfolio_profile }
  let(:attachments) { {} }
  let(:mailer) { instance_double(ActionMailer::Base, attachments:) }

  it "attaches the resume blob when no URL is configured" do
    profile.resume.attach(
      io: StringIO.new("%PDF-1.4 test resume"),
      filename: "curriculo.pdf",
      content_type: "application/pdf"
    )

    described_class.call(mailer:, profile:)

    expect(attachments.keys).to include("curriculo.pdf")
  end

  it "downloads and attaches the resume from a configured URL" do
    profile.update!(resume_url: "https://example.com/resume.pdf")
    allow(Portfolio::RemoteAssetUrl).to receive(:download).with(profile.resume_url).and_return("%PDF-1.4 remote resume")
    allow(Portfolio::RemoteAssetUrl).to receive(:normalize).and_return(
      Portfolio::RemoteAssetUrl::Resource.new(
        original_url: profile.resume_url,
        preview_url: profile.resume_url,
        open_url: profile.resume_url,
        download_url: profile.resume_url,
        content_type: "application/pdf",
        filename: "resume.pdf"
      )
    )

    described_class.call(mailer:, profile:)

    expect(attachments.keys).to include("resume.pdf")
  end
end
