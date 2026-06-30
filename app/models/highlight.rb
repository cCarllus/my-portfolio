require "securerandom"
require "uri"

class Highlight < ApplicationRecord
  include LocalizedFields

  HEX_COLOR = /\A#[0-9a-f]{6}\z/i
  SOURCES = %w[manual github].freeze
  CATEGORIES = %w[project highlight open_source].freeze

  belongs_to :portfolio_profile

  scope :ordered, -> { order(:position, :id) }
  scope :published, -> { where(published: true) }

  before_validation :assign_random_category_color,
    if: -> { category_color.blank? || !category_color.match?(HEX_COLOR) }

  validates :source, inclusion: { in: SOURCES }
  validates :category, inclusion: { in: CATEGORIES }
  validates :category_color, format: { with: HEX_COLOR }
  validates :github_repository_id, presence: true, uniqueness: { scope: :portfolio_profile_id }, if: :github?
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :external_url_is_http

  def github? = source == "github"
  def manual? = source == "manual"

  private

  def assign_random_category_color
    self.category_color = format("#%06x", SecureRandom.random_number(0x1000000))
  end

  def external_url_is_http
    return if external_url.blank?

    uri = URI.parse(external_url)
    return if uri.scheme.in?(%w[http https]) && uri.host.present?

    errors.add(:external_url, :invalid)
  rescue URI::InvalidURIError
    errors.add(:external_url, :invalid)
  end
end
