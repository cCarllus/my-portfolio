module Portfolio
  class RenderEmail
    FALLBACKS = {
      "pt" => { contact_name: "tudo bem", company_name: "sua empresa", job_title: "uma oportunidade" },
      "en" => { contact_name: "there", company_name: "your company", job_title: "an opportunity" }
    }.freeze

    def initialize(profile:, contact_request:)
      @profile = profile
      @contact_request = contact_request
    end

    def subject
      profile.localized(:email_subjects, locale)
    end

    def body
      replace_placeholders(profile.localized(:email_bodies, locale).to_s)
    end

    private

    attr_reader :profile, :contact_request

    def locale
      contact_request.locale
    end

    def replace_placeholders(template)
      fallback = FALLBACKS.fetch(locale, FALLBACKS.fetch("pt"))
      template
        .gsub("{{nome_contato}}", contact_request.contact_name.presence || fallback[:contact_name])
        .gsub("{{nome_empresa}}", contact_request.company_name.presence || fallback[:company_name])
        .gsub("{{nome_vaga}}", contact_request.job_title.presence || fallback[:job_title])
    end
  end
end
