module LocalizedFields
  extend ActiveSupport::Concern

  def localized(attribute, locale = I18n.locale)
    values = public_send(attribute) || {}
    values[locale.to_s].presence ||
      values[I18n.default_locale.to_s].presence ||
      values.values.find(&:present?)
  end
end
