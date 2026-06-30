profile = PortfolioProfile.first_or_initialize
profile.update!(
  full_name: "Carlos Henrique Caldeira",
  nickname: "Rick",
  roles: {
    pt: "Engenheiro de Software Full Stack Sênior",
    en: "Senior Full Stack Software Engineer"
  },
  locations: { pt: "Brasil", en: "Brazil" },
  philosophies: {
    pt: "Arquitetura limpa • Impacto real",
    en: "Clean Architecture • Real impact"
  },
  map_labels: {
    pt: "São Bernardo do Campo, SP",
    en: "São Bernardo do Campo, Brazil"
  },
  contact_email: "crick.lucas@gmail.com",
  phone: "+55 (13) 99101-8860",
  linkedin_url: "https://linkedin.com/in/carlos-henrique-caldeira",
  github_url: "https://github.com/oCarllus",
  map_x_percent: 35,
  map_y_percent: 60,
  email_subjects: {
    pt: "Carlos Henrique Caldeira | Engenheiro de Software Full Stack",
    en: "Carlos Henrique Caldeira | Full Stack Software Engineer"
  },
  email_bodies: {
    pt: <<~BODY,
      Olá, {{nome_contato}}!

      Obrigado por deixar seu contato em meu portfólio. Conforme solicitado, envio uma apresentação mais completa sobre minha experiência profissional. Meu currículo também está anexado.

      Sou Engenheiro de Software Full Stack, com mais de quatro anos de experiência no desenvolvimento, arquitetura e manutenção de aplicações web escaláveis. Minha principal experiência inclui Ruby on Rails, Node.js, TypeScript, Vue.js, PostgreSQL, MySQL, Docker, AWS, APIs RESTful, RSpec, Jest e TDD.

      Entre os resultados alcançados, destaco a otimização de consultas SQL, reduzindo em até 40% a latência de APIs críticas, além de melhorias com Clean Architecture, SOLID e Design Patterns.

      Caso meu perfil esteja alinhado às oportunidades da {{nome_empresa}}, fico à disposição para uma conversa ou avaliação técnica.

      Atenciosamente,
      Carlos Henrique Caldeira
      Engenheiro de Software Full Stack
      Telefone: +55 (13) 99101-8860
      E-mail: crick.lucas@gmail.com
      LinkedIn: linkedin.com/in/carlos-henrique-caldeira
      GitHub: github.com/oCarllus
    BODY
    en: <<~BODY
      Hello, {{nome_contato}}!

      Thank you for requesting more information through my portfolio. I am a Full Stack Software Engineer with more than four years of experience building and evolving scalable web applications with Ruby on Rails, Node.js, TypeScript, PostgreSQL, AWS and automated testing.

      I have reduced critical API latency by up to 40% and led architecture improvements using Clean Architecture, SOLID and Design Patterns.

      If my profile matches an opportunity at {{nome_empresa}}, I would be glad to discuss the team's challenges. My resume is attached.

      Best regards,
      Carlos Henrique Caldeira
    BODY
  }
)

avatar_path = Rails.root.join("app/assets/images/carlos-henrique-caldeira.png")
unless profile.avatar.attached?
  profile.avatar.attach(io: File.open(avatar_path), filename: avatar_path.basename, content_type: "image/png")
end

resume_path = Rails.root.join("public/documents/carlos-henrique-caldeira-curriculo.pdf")
unless profile.resume.attached?
  profile.resume.attach(io: File.open(resume_path), filename: "Carlos_Henrique_Caldeira_Curriculo.pdf", content_type: "application/pdf")
end

[
  [ "Ruby on Rails", "backend" ],
  [ "Node.js + TypeScript", "backend" ],
  [ "Python", "backend" ],
  [ "AWS", "cloud" ],
  [ "PostgreSQL", "database" ],
  [ "Clean Architecture", "architecture" ],
  [ "LLMs e IA", "ai" ],
  [ "TDD", "quality" ]
].each_with_index do |(name, category), position|
  profile.skills.find_or_initialize_by(name:).update!(
    category:,
    position:,
    featured: position < 5,
    published: true
  )
end

[
  {
    company: "Monde Sistemas",
    period: "2025 — 2026",
    roles: { pt: "Engenheiro de Software Sênior Full Stack", en: "Senior Full Stack Software Engineer" },
    locations: { pt: "Americana, SP · Remoto", en: "Americana, Brazil · Remote" },
    summaries: { pt: "APIs RESTful escaláveis, performance SQL, AWS, testes automatizados e integrações com LLMs." }
  },
  {
    company: "MetaOriginal",
    period: "2023 — 2025",
    roles: { pt: "Engenheiro de Software Full Stack", en: "Full Stack Software Engineer" },
    locations: { pt: "Miami, EUA · Remoto", en: "Miami, USA · Remote" },
    summaries: { pt: "Aplicações internacionais com Rails, Node.js, Vue.js, AWS e Firebase." }
  },
  {
    company: "Lemon & Kiwi",
    period: "2021 — 2023",
    roles: { pt: "Desenvolvedor Full Stack Júnior", en: "Junior Full Stack Developer" },
    locations: { pt: "São Paulo, SP · Remoto", en: "São Paulo, Brazil · Remote" },
    summaries: { pt: "Plataformas web com Ruby on Rails e JavaScript, testes e deploy contínuo." }
  }
].each_with_index do |attributes, position|
  experience = profile.experiences.find_or_initialize_by(company: attributes.fetch(:company))
  experience.update!(**attributes, position:, published: true)
end

[
  [ "40%", "Performance de APIs", "Até 40% menos latência", "API performance", "Up to 40% lower latency" ],
  [ "AWS", "Integrações cloud-native", "JWT, webhooks e comunicação assíncrona", "Cloud-native integrations", "JWT, webhooks and asynchronous communication" ],
  [ "IA", "Automações com IA", "APIs de LLMs e análise textual", "AI automation", "LLM APIs and text analysis" ]
].each_with_index do |values, position|
  metric, pt_title, pt_description, en_title, en_description = values
  highlight = profile.highlights.find_or_initialize_by(position:)
  highlight.update!(
    metric:,
    titles: { pt: pt_title, en: en_title },
    descriptions: { pt: pt_description, en: en_description },
    published: true
  )
end

[
  {
    courses: { pt: "Análise e Desenvolvimento de Sistemas", en: "Systems Analysis and Development" },
    institutions: { pt: "FATEC-SP", en: "FATEC-SP" },
    statuses: { pt: "Concluído em 2023", en: "Completed in 2023" }
  },
  {
    courses: { pt: "Bacharelado em Economia", en: "Bachelor's degree in Economics" },
    institutions: { pt: "Universidade FGV", en: "FGV University" },
    statuses: { pt: "Em andamento", en: "In progress" }
  }
].each_with_index do |attributes, position|
  profile.educations.find_or_initialize_by(position:).update!(**attributes, published: true)
end

[
  {
    content_kind: "about",
    titles: { pt: "Sobre mim", en: "About me" },
    bodies: {
      pt: "Engenheiro de Software Full Stack com mais de quatro anos de experiência em aplicações web escaláveis, Ruby on Rails, Node.js, AWS e IA/LLMs.",
      en: "Full Stack Software Engineer with more than four years of experience in scalable web applications, Ruby on Rails, Node.js, AWS and AI/LLMs."
    }
  },
  {
    content_kind: "experience",
    titles: { pt: "Experiência", en: "Experience" },
    bodies: {}
  },
  {
    content_kind: "skills",
    titles: { pt: "Competências", en: "Skills" },
    bodies: {}
  },
  {
    content_kind: "highlights",
    titles: { pt: "Destaques", en: "Highlights" },
    bodies: {}
  },
  {
    content_kind: "education",
    titles: { pt: "Formação", en: "Education" },
    bodies: {}
  },
  {
    content_kind: "resume",
    titles: { pt: "Currículo", en: "Resume" },
    bodies: { pt: "Currículo profissional completo em PDF.", en: "Complete professional resume in PDF." },
    uses_resume: true
  }
].each_with_index do |attributes, position|
  document = profile.portfolio_documents.find_or_initialize_by(content_kind: attributes.fetch(:content_kind))
  document.update!(**attributes, position:, published: true)
end
