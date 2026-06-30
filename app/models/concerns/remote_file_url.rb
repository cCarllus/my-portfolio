module RemoteFileUrl
  extend ActiveSupport::Concern

  HTTP_URL_FORMAT = {
    with: %r{\Ahttps?://.+\z}i,
    message: :invalid
  }.freeze

  class_methods do
    def validates_remote_file_url(*attributes)
      attributes.each do |attribute|
        validates attribute, format: HTTP_URL_FORMAT, allow_blank: true
      end
    end
  end
end
