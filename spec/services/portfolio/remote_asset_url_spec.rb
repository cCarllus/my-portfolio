require "rails_helper"

RSpec.describe Portfolio::RemoteAssetUrl do
  describe ".normalize" do
    it "converts Google Drive share links into preview and download URLs" do
      url = "https://drive.google.com/file/d/abc123/view?usp=sharing"
      resource = described_class.normalize(url, kind: :pdf)

      expect(resource.preview_url).to eq("https://drive.google.com/file/d/abc123/preview")
      expect(resource.open_url).to eq("https://drive.google.com/file/d/abc123/preview")
      expect(resource.download_url).to eq("https://drive.google.com/uc?export=download&id=abc123")
      expect(resource.content_type).to eq("application/pdf")
    end

    it "keeps direct PDF URLs unchanged" do
      url = "https://example.com/files/resume.pdf"
      resource = described_class.normalize(url, kind: :pdf)

      expect(resource.preview_url).to eq(url)
      expect(resource.download_url).to eq(url)
      expect(resource.content_type).to eq("application/pdf")
    end

    it "detects image URLs" do
      url = "https://example.com/avatar.png"
      resource = described_class.normalize(url, kind: :image)

      expect(resource.content_type).to eq("image/png")
    end
  end
end
