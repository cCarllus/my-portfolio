require "digest"

module Admin
  class Credentials
    class << self
      def valid?(email, password)
        secure_match?(email, ENV["ADMIN_EMAIL"]) &&
          secure_match?(password, ENV["ADMIN_PASSWORD"])
      end

      def trigger_email?(email)
        secure_match?(email.to_s.strip.downcase, ENV["ADMIN_TRIGGER_EMAIL"].to_s.strip.downcase)
      end

      private

      def secure_match?(provided, expected)
        return false if expected.blank?

        ActiveSupport::SecurityUtils.secure_compare(
          Digest::SHA256.hexdigest(provided.to_s),
          Digest::SHA256.hexdigest(expected.to_s)
        )
      end
    end
  end
end
