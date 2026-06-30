class PortfolioPresenter
  SKILLS_PREVIEW_LIMIT = 8

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
      projects: highlights.map { |item| { name: item.localized(:titles, locale), role: item.localized(:descriptions, locale), period: item.metric } },
      education: educations.map { |item| { name: item.localized(:courses, locale), role: item.localized(:institutions, locale), period: item.localized(:statuses, locale) } }
    }
  end

  def document_attachment(document)
    return profile.resume if document.uses_resume? && profile.resume.attached?
    return document.file if document.file.attached?

    nil
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
end
