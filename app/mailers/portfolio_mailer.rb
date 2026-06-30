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
    Portfolio::AttachResumeToEmail.call(mailer: self, profile: @profile)
  end
end
