class PortfolioDocument < ApplicationRecord
  include LocalizedFields

  CONTENT_KINDS = %w[about experience skills highlights education resume custom].freeze
  DERIVED_KINDS = %w[experience skills highlights education].freeze

  belongs_to :portfolio_profile
  has_one_attached :file

  scope :ordered, -> { order(:position, :id) }
  scope :published, -> { where(published: true) }

  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :content_kind, inclusion: { in: CONTENT_KINDS }

  def derived?
    content_kind.in?(DERIVED_KINDS)
  end

  def system?
    content_kind != "custom"
  end
end
