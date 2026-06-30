require "net/http"
require "uri"

module Portfolio
  class RemoteAssetUrl
    Resource = Data.define(:original_url, :preview_url, :open_url, :download_url, :content_type, :filename)

    GOOGLE_DRIVE_ID = %r{drive\.google\.com/file/d/([^/]+)}
    GOOGLE_DRIVE_OPEN = %r{[?&]id=([^&]+)}

    def self.normalize(url, kind:)
      new(url, kind:).normalize
    end

    def self.download(url)
      new(url).download
    end

    def initialize(url, kind: :file)
      @url = url.to_s.strip
      @kind = kind
    end

    def normalize
      return if url.blank?

      Resource.new(
        original_url: url,
        preview_url: preview_url,
        open_url: open_url,
        download_url: download_url,
        content_type: content_type,
        filename: filename
      )
    end

    def download
      resource = normalize
      raise ArgumentError, "invalid remote asset url" unless resource

      response = http_get(resource.download_url)
      raise ArgumentError, "remote asset download failed" unless response.is_a?(Net::HTTPSuccess)

      response.body
    end

    private

    attr_reader :url, :kind

    def preview_url
      return google_drive_url(:preview) if google_drive_id

      url
    end

    def open_url
      return google_drive_url(:preview) if google_drive_id

      url
    end

    def download_url
      return "https://drive.google.com/uc?export=download&id=#{google_drive_id}" if google_drive_id

      url
    end

    def content_type
      return "application/pdf" if kind == :pdf || pdf_url?

      return "image/png" if image_url? && url.downcase.end_with?(".png")
      return "image/jpeg" if image_url? && url.downcase.match?(/\.jpe?g\z/)
      return "image/webp" if image_url? && url.downcase.end_with?(".webp")
      return "image/gif" if image_url? && url.downcase.end_with?(".gif")

      kind == :image ? "image/*" : "application/octet-stream"
    end

    def filename
      URI.parse(url).path.split("/").last.presence || default_filename
    rescue URI::InvalidURIError
      default_filename
    end

    def default_filename
      kind == :pdf ? "resume.pdf" : "file"
    end

    def pdf_url?
      url.downcase.include?(".pdf") || google_drive_id.present?
    end

    def image_url?
      kind == :image
    end

    def google_drive_id
      @google_drive_id ||= url[GOOGLE_DRIVE_ID, 1] || url[GOOGLE_DRIVE_OPEN, 1]
    end

    def google_drive_url(action)
      "https://drive.google.com/file/d/#{google_drive_id}/#{action}"
    end

    def http_get(target_url, limit: 5)
      raise ArgumentError, "too many redirects" if limit.zero?

      uri = URI.parse(target_url)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(Net::HTTP::Get.new(uri))
      end

      return http_get(response["location"], limit: limit - 1) if response.is_a?(Net::HTTPRedirection)

      response
    end
  end
end