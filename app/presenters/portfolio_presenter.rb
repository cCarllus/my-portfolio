class PortfolioPresenter
  SKILLS_PREVIEW_LIMIT = 8
  DocumentResource = Data.define(:preview_url, :open_url, :download_url, :content_type, :attachment) do
    def url_based?
      attachment.nil?
    end
  end

  attr_reader :profile

  def initialize(profile, locale: I18n.locale)
    @profile = profile
    @locale = locale
  end

  def full_name = profile.full_name
  def nickname = profile.nickname
  def class_name
    parts = full_name.split
    [ parts.first, parts.last ].compact.join.gsub(/[^A-Za-zÀ-ÿ0-9]/, "")
  end
  def role = profile.localized(:roles, locale)
  def location = profile.localized(:locations, locale)
  def philosophy = profile.localized(:philosophies, locale)
  def summary
    markdown = about_document&.localized(:bodies, locale)
    return role if markdown.blank?

    ActionView::Base.full_sanitizer.sanitize(
      Portfolio::MarkdownRenderer.call(markdown)
    ).squish
  end
  def map_label = profile.localized(:map_labels, locale)
  def map_x_percent = profile.map_x_percent
  def map_y_percent = profile.map_y_percent

  def skills
    @skills ||= profile.skills.published.ordered.to_a
  end

  def code_stack
    skills.select(&:featured?).first(5).map(&:name)
  end

  def skill_lanes
    skills.first(SKILLS_PREVIEW_LIMIT).each_with_index
      .partition { |(_, index)| index.even? }
      .map { |lane| lane.map(&:first) }
  end

  def skills_overflow?
    skills.size > SKILLS_PREVIEW_LIMIT
  end

  def experiences
    profile.experiences.published.ordered
  end

  def highlights
    profile.highlights.published.ordered
  end

  def educations
    profile.educations.published.ordered
  end

  def documents
    @documents ||= profile.portfolio_documents.published.ordered.with_attached_file.to_a
  end

  def skill_groups
    skills.group_by(&:category)
  end

  def about_document
    documents.find { |document| document.content_kind == "about" }
  end

  def tab_items
    {
      work: experiences.map { |item| { name: item.company, role: item.localized(:roles, locale), period: item.period } },
      projects: highlights.first(3).map do |item|
        {
          name: item.localized(:titles, locale),
          role: plain_project_description(item),
          period: item.metric.presence || item.primary_language
        }
      end,
      education: educations.map { |item| { name: item.localized(:courses, locale), role: item.localized(:institutions, locale), period: item.localized(:statuses, locale) } }
    }
  end

  def avatar_display_url
    return profile.avatar_url if profile.avatar_url.present?
    return nil unless profile.avatar.attached?

    profile.avatar
  end

  def avatar_available?
    profile.avatar_url.present? || profile.avatar.attached?
  end

  def document_resource(document)
    if document.uses_resume?
      resume_resource || file_resource(document)
    else
      file_resource(document)
    end
  end

  def social_links
    [
      [ "E-mail", "mailto:#{profile.contact_email}" ],
      [ "LinkedIn", profile.linkedin_url ],
      [ "GitHub", profile.github_url ]
    ].select { |(_, url)| url.present? }
  end

  private

  attr_reader :locale

  def plain_project_description(item)
    ActionView::Base.full_sanitizer.sanitize(
      Portfolio::MarkdownRenderer.call(item.localized(:descriptions, locale))
    ).squish
  end

  def resume_resource
    if profile.resume_url.present?
      remote_resource(profile.resume_url, kind: :pdf)
    elsif profile.resume.attached?
      attachment_resource(profile.resume)
    end
  end

  def file_resource(document)
    if document.file_url.present?
      remote_resource(document.file_url, kind: file_kind(document.file_url))
    elsif document.file.attached?
      attachment_resource(document.file)
    end
  end

  def remote_resource(url, kind:)
    asset = Portfolio::RemoteAssetUrl.normalize(url, kind:)
    return unless asset

    DocumentResource.new(
      preview_url: asset.preview_url,
      open_url: asset.open_url,
      download_url: asset.download_url,
      content_type: asset.content_type,
      attachment: nil
    )
  end

  def attachment_resource(attachment)
    DocumentResource.new(
      preview_url: nil,
      open_url: nil,
      download_url: nil,
      content_type: attachment.content_type,
      attachment:
    )
  end

  def file_kind(url)
    url.downcase.match?(/\.(png|jpe?g|gif|webp)(\?|$)/) ? :image : :file
  end
end
