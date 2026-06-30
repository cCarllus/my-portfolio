module Portfolio
  class AttachResumeToEmail
    def self.call(mailer:, profile:)
      new(mailer:, profile:).call
    end

    def initialize(mailer:, profile:)
      @mailer = mailer
      @profile = profile
    end

    def call
      if profile.resume_url.present?
        attach_from_url
      elsif profile.resume.attached?
        attach_from_blob
      end
    end

    private

    attr_reader :mailer, :profile

    def attach_from_url
      resource = RemoteAssetUrl.normalize(profile.resume_url, kind: :pdf)
      return unless resource

      mailer.attachments[resource.filename] = {
        mime_type: resource.content_type,
        content: RemoteAssetUrl.download(profile.resume_url)
      }
    rescue ArgumentError, Net::OpenTimeout, Net::ReadTimeout, SocketError => error
      Rails.logger.error("[Portfolio::AttachResumeToEmail] #{error.class}: #{error.message}")
    end

    def attach_from_blob
      mailer.attachments[profile.resume.filename.to_s] = {
        mime_type: profile.resume.content_type,
        content: profile.resume.download
      }
    end
  end
end