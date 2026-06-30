class Experience < ApplicationRecord
  include LocalizedFields

  belongs_to :portfolio_profile

  scope :ordered, -> { order(:position, :id) }
  scope :published, -> { where(published: true) }

  validates :company, :period, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
