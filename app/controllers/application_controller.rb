class ApplicationController < ActionController::Base
  around_action :switch_locale

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def switch_locale(&action)
    locale = params[:locale]&.to_sym
    locale = I18n.default_locale unless I18n.available_locales.include?(locale)

    I18n.with_locale(locale, &action)
  end
end
