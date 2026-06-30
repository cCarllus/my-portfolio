class PortfolioProfile < ApplicationRecord
  include LocalizedFields
  include RemoteFileUrl

  has_many :skills, dependent: :destroy
  has_many :experiences, dependent: :destroy
  has_many :highlights, dependent: :destroy
  has_many :educations, dependent: :destroy
  has_many :portfolio_documents, dependent: :destroy

  has_one_attached :avatar
  has_one_attached :resume

  validates :full_name, presence: true
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :map_x_percent, :map_y_percent, numericality: { in: 0..100 }
  validates_remote_file_url :avatar_url, :resume_url
  validate :resume_is_pdf

  def self.current
    first
  end

  def self.current!
    first!
  end

  private

  def resume_is_pdf
    return unless resume.attached? && resume.blob.content_type != "application/pdf"

    errors.add(:resume, :invalid)
  end
end
