module Admin::ApplicationHelper
  def translated_value(record, attribute, locale)
    (record.public_send(attribute) || {})[locale.to_s]
  end

  def portfolio_document_management_path(document)
    case document.content_kind
    when "experience" then admin_experiences_path
    when "skills" then admin_skills_path
    when "highlights" then admin_highlights_path
    when "education" then admin_educations_path
    when "resume" then edit_admin_email_template_path
    end
  end
end
