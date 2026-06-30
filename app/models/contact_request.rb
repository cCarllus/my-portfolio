class ContactRequest < ApplicationRecord
  enum :status, { pending: "pending", sent: "sent", failed: "failed" }, validate: true

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :locale, inclusion: { in: I18n.available_locales.map(&:to_s) }

  before_validation :normalize_email

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
