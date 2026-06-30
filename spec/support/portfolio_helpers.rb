module PortfolioHelpers
  def create_portfolio_profile
    PortfolioProfile.create!(
      full_name: "Carlos Henrique Caldeira",
      nickname: "Rick",
      roles: { pt: "Engenheiro de Software Full Stack", en: "Full Stack Software Engineer" },
      locations: { pt: "Brasil", en: "Brazil" },
      philosophies: { pt: "Arquitetura limpa", en: "Clean Architecture" },
      summaries: { pt: "Resumo profissional", en: "Professional summary" },
      map_labels: { pt: "São Bernardo do Campo, SP", en: "São Bernardo do Campo, Brazil" },
      email_subjects: { pt: "Apresentação profissional", en: "Professional introduction" },
      email_bodies: {
        pt: "Olá, {{nome_contato}}! Perfil para {{nome_empresa}}.",
        en: "Hello, {{nome_contato}}! Profile for {{nome_empresa}}."
      },
      contact_email: "crick.lucas@gmail.com",
      map_x_percent: 35,
      map_y_percent: 60
    )
  end

  def create_portfolio_content
    profile = create_portfolio_profile
    %w[Ruby\ on\ Rails Node.js\ +\ TS Python AWS PostgreSQL].each_with_index do |name, index|
      profile.skills.create!(name:, position: index, featured: true, published: true)
    end
    profile.experiences.create!(
      company: "Monde Sistemas",
      period: "2025 — 2026",
      roles: { pt: "Engenheiro de Software Sênior Full Stack" },
      position: 0
    )
    profile.highlights.create!(
      metric: "40%",
      titles: { pt: "Performance de APIs" },
      descriptions: { pt: "Até 40% menos latência" },
      position: 0
    )
    profile.educations.create!(
      courses: { pt: "Análise e Desenvolvimento de Sistemas" },
      institutions: { pt: "FATEC-SP" },
      statuses: { pt: "Concluído em 2023" },
      position: 0
    )
    profile.portfolio_documents.create!(
      content_kind: "about",
      titles: { pt: "Sobre mim" },
      bodies: { pt: "mais de quatro anos de experiência profissional." },
      position: 0
    )
    profile.resume.attach(
      io: StringIO.new("%PDF-1.4 resume"),
      filename: "curriculo.pdf",
      content_type: "application/pdf"
    )
    profile.portfolio_documents.create!(
      content_kind: "resume",
      titles: { pt: "Currículo" },
      bodies: { pt: "Currículo completo." },
      position: 5,
      uses_resume: true
    )
    {
      experience: "Experiência",
      skills: "Competências",
      highlights: "Destaques",
      education: "Formação"
    }.each_with_index do |(content_kind, title), index|
      profile.portfolio_documents.create!(
        content_kind:,
        titles: { pt: title },
        bodies: {},
        position: index + 1
      )
    end
    profile
  end
end

RSpec.configure do |config|
  config.include PortfolioHelpers
end
