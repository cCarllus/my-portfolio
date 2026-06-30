require "rails_helper"

RSpec.describe PortfolioPresenter do
  let(:profile) { create_portfolio_profile }
  let(:presenter) { described_class.new(profile) }

  describe "#avatar_display_url" do
    it "prefers the configured avatar URL" do
      profile.update!(avatar_url: "https://example.com/avatar.png")

      expect(presenter.avatar_display_url).to eq("https://example.com/avatar.png")
    end
  end

  describe "#document_resource" do
    it "builds a remote resume resource from the profile URL" do
      profile.update!(resume_url: "https://drive.google.com/file/d/abc123/view")
      document = profile.portfolio_documents.create!(
        content_kind: "resume",
        titles: { pt: "Currículo" },
        uses_resume: true,
        position: 0
      )

      resource = presenter.document_resource(document)

      expect(resource.preview_url).to include("/preview")
      expect(resource.download_url).to include("export=download")
      expect(resource).to be_url_based
    end
  end
end
