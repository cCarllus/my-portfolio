require "securerandom"

class Skill < ApplicationRecord
  HEX_COLOR = /\A#[0-9a-f]{6}\z/i

  belongs_to :portfolio_profile

  scope :ordered, -> { order(:position, :id) }
  scope :published, -> { where(published: true) }
  scope :featured, -> { where(featured: true) }

  before_validation :assign_random_color, if: -> { color.blank? || !color.match?(HEX_COLOR) }

  validates :name, :category, :color, presence: true
  validates :color, format: { with: HEX_COLOR }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  private

  def assign_random_color
    self.color = format("#%06x", SecureRandom.random_number(0x1000000))
  end
end
