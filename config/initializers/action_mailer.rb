Rails.application.configure do
  config.action_mailer.default_url_options = {
    host: ENV.fetch("APP_HOST", "localhost"),
    port: ENV["APP_PORT"],
    protocol: ENV.fetch("APP_PROTOCOL", "http")
  }.compact

  if !Rails.env.test? && ENV["SMTP_ADDRESS"].present?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.smtp_settings = {
      address: ENV.fetch("SMTP_ADDRESS"),
      port: ENV.fetch("SMTP_PORT", 587),
      user_name: ENV["SMTP_USERNAME"],
      password: ENV["SMTP_PASSWORD"],
      authentication: ENV.fetch("SMTP_AUTHENTICATION", "plain"),
      enable_starttls_auto: ActiveModel::Type::Boolean.new.cast(
        ENV.fetch("SMTP_ENABLE_STARTTLS_AUTO", "true")
      )
    }
  end
end
