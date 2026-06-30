class PortfolioMailer < ApplicationMailer
  def presentation
    @contact_request = params.fetch(:contact_request)
    @profile = PortfolioProfile.current!
    rendered_email = Portfolio::RenderEmail.new(profile: @profile, contact_request: @contact_request)
    @body = rendered_email.body

    attach_resume
    mail(to: @contact_request.email, subject: rendered_email.subject)
  end

  private

  def attach_resume
    return unless @profile.resume.attached?

    attachments[@profile.resume.filename.to_s] = {
      mime_type: @profile.resume.content_type,
      content: @profile.resume.download
    }
  end
end
