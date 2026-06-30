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
  linkedin_url: "https://www.linkedin.com/in/ccarlos-henrique",
  github_url: "https://github.com/cCarllus",
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

      Sou **Engenheiro de Software Full Stack**, com mais de quatro anos de experiência no desenvolvimento, arquitetura e manutenção de aplicações web escaláveis.

      Minha principal experiência inclui:

      * **Ruby on Rails**
      * **Node.js**
      * **TypeScript**
      * **Vue.js**
      * **PostgreSQL e MySQL**
      * **Docker**
      * **AWS**
      * **APIs RESTful**
      * **RSpec e Jest**
      * **Test-Driven Development — TDD**

      Entre os resultados alcançados, destaco a otimização de consultas SQL, reduzindo em até **40% a latência de APIs críticas**, além da implementação de melhorias arquiteturais baseadas em:

      * Clean Architecture
      * SOLID
      * Design Patterns
      * Boas práticas de performance e escalabilidade

      Caso meu perfil esteja alinhado às oportunidades da {{nome_empresa}}, fico à disposição para uma conversa ou avaliação técnica.

      Atenciosamente,
      Carlos Henrique Caldeira
      Engenheiro de Software Full Stack
      Telefone: +55 (13) 99101-8860
      E-mail: crick.lucas@gmail.com
      LinkedIn: https://www.linkedin.com/in/ccarlos-henrique
      GitHub: https://github.com/cCarllus
    BODY
    en: <<~BODY
      Hello, {{nome_contato}}!

      Thank you for leaving your contact details on my portfolio. As requested, I am sending a more detailed overview of my professional experience. My resume is also attached.

      I am a **Full Stack Software Engineer** with over four years of experience in the development, architecture, and maintenance of scalable web applications.

      My core expertise includes:

      * **Ruby on Rails**
      * **Node.js**
      * **TypeScript**
      * **Vue.js**
      * **PostgreSQL and MySQL**
      * **Docker**
      * **AWS**
      * **RESTful APIs**
      * **RSpec and Jest**
      * **Test-Driven Development (TDD)**

      Key achievements include optimizing SQL queries—reducing latency in critical APIs by up to **40%**—and implementing architectural improvements based on:

      * Clean Architecture
      * SOLID principles
      * Design Patterns
      * Performance and scalability best practices

      If my profile aligns with opportunities at **{{nome_empresa}}**, I am available for a conversation or a technical assessment.

      Best regards,
      **Carlos Henrique Caldeira**
      Full Stack Software Engineer

      **Phone:** +55 (13) 99101-8860
      **Email:** [crick.lucas@gmail.com](mailto:crick.lucas@gmail.com)
      **LinkedIn:** https://www.linkedin.com/in/ccarlos-henrique
      **GitHub:** https://github.com/cCarllus
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
  [ "Ruby & Ruby on Rails", "backend", "#C830E9", true ],
  [ "Node.js + TypeScript", "backend", "#942192", true ],
  [ "Python", "backend", "#EF3F4F", true ],
  [ "AWS", "cloud", "#2F6930", true ],
  [ "PostgreSQL, MySQL e Firebase", "database", "#8E9DA4", true ],
  [ "Clean Architecture", "architecture", "#F64B92", false ],
  [ "LLMs e IA", "ai", "#5313A9", false ],
  [ "TDD & SDD", "quality", "#DCE8B7", false ],
  [ "React, Vue.js, Vite, TailwindCSS & Bootstrap", "Frontend", "#307A4A", true ],
  [ "Docker, Linux, GitLab CI/CD e Git", "DevOps", "#73FADD", true ],
  [ "REST APIs, JWT/OAuth ", "backend", "#207CB1", true ],
  [ "Clean Code, SOLID, Design Patterns e Clean Architecture", "Metodologias & Arquitetura", "#9F0B5A", true ]
].each_with_index do |(name, category, color, featured), position|
  profile.skills.find_or_initialize_by(name:).update!(
    category:,
    color:,
    position:,
    featured:,
    published: true
  )
end
profile.skills.where.not(name: [
  "Ruby & Ruby on Rails",
  "Node.js + TypeScript",
  "Python",
  "AWS",
  "PostgreSQL, MySQL e Firebase",
  "Clean Architecture",
  "LLMs e IA",
  "TDD & SDD",
  "React, Vue.js, Vite, TailwindCSS & Bootstrap",
  "Docker, Linux, GitLab CI/CD e Git",
  "REST APIs, JWT/OAuth ",
  "Clean Code, SOLID, Design Patterns e Clean Architecture"
]).destroy_all

[
  {
    company: "Monde Sistemas",
    period: "2025 — 2026",
    roles: { pt: "Engenheiro de Software Sênior Full Stack", en: "Senior Full Stack Software Engineer" },
    locations: { pt: "Americana, SP · Remoto", en: "Americana, Brazil · Remote" },
    summaries: {
      pt: "Eu trabalho na manutenção e desenvolvimento de funcionalidades para aplicações Delphi e APIs Ruby on Rails, incluindo diversas tecnologias relacionadas como Postgres, Redis, Sidekiq, RSpec, etc.",
      en: "I work on the maintenance and feature development of Delphi applications and Ruby on Rails APIs, including various related technologies such as Postgres, Redis, Sidekiq, RSpec, etc."
    }
  },
  {
    company: "MetaOriginal",
    period: "2023 — 2025",
    roles: { pt: "Engenheiro de Software Full Stack", en: "Full Stack Software Engineer" },
    locations: { pt: "Miami, EUA · Remoto", en: "Miami, USA · Remote" },
    summaries: {
      pt: <<~MARKDOWN,
        - Desenvolvimento de aplicações web, com foco em performance e boas práticas
        de codificação.

        - Manutenção e evolução de APIs REST, garantindo estabilidade e segurança das
        integrações.

        - Suporte técnico e colaboração direta com a equipe de desenvolvimento,
        auxiliando na resolução de problemas e no aprimoramento de soluções.
      MARKDOWN
      en: <<~MARKDOWN
        - Development of web applications, focusing on performance and coding best practices.

        - Maintenance and evolution of REST APIs, ensuring the stability and security of integrations.

        - Technical support and direct collaboration with the development team, assisting in troubleshooting and the enhancement of solutions.
      MARKDOWN
    }
  },
  {
    company: "Lemon & Kiwi",
    period: "2021 — 2023",
    roles: { pt: "Desenvolvedor Full Stack Júnior", en: "Junior Full Stack Developer" },
    locations: { pt: "São Paulo, SP · Remoto", en: "São Paulo, Brazil · Remote" },
    summaries: {
      pt: <<~MARKDOWN,
        - Apoio no desenvolvimento de aplicações web, acompanhando e auxiliando
        profissionais plenos e seniors nas demandas, com foco em aprendizado
        contínuo e boas práticas de codificação.

        - Colaboração na manutenção e evolução de APIs REST, contribuindo para ajustes
        e melhorias sob orientação da equipe, visando estabilidade e segurança nas
        integrações.

        - Suporte técnico e participação ativa na rotina da equipe de desenvolvimento,
        auxiliando na resolução de problemas e na execução de tarefas, enquanto
        aprimora conhecimento prático em ambiente profissional.
      MARKDOWN
      en: <<~MARKDOWN
        - Support the development of web applications by working alongside and assisting mid-level and senior professionals with project requirements, focusing on continuous learning and coding best practices.

        - Collaborate on the maintenance and evolution of REST APIs, contributing to adjustments and improvements under team guidance to ensure integration stability and security.

        - Provide technical support and actively participate in the development team's daily operations, assisting with troubleshooting and task execution while gaining practical experience in a professional environment.
      MARKDOWN
    }
  }
].each_with_index do |attributes, position|
  experience = profile.experiences.find_or_initialize_by(company: attributes.fetch(:company))
  experience.update!(**attributes, position:, published: true)
end
profile.experiences.where.not(company: [ "Monde Sistemas", "MetaOriginal", "Lemon & Kiwi" ]).destroy_all

[
  [ "40%", "Performance de APIs", "Arquitetei otimizações de consultas SQL complexas, reduzindo latência de APIs críticas em até 40%.", "API performance", "I architected optimizations for complex SQL queries, reducing the latency of critical APIs by up to 40%." ],
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
profile.highlights.where.not(position: 0..2).destroy_all

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
profile.educations.where.not(position: 0..1).destroy_all

[
  {
    content_kind: "about",
    titles: { pt: "Sobre mim", en: "About me" },
    bodies: {
      pt: <<~MARKDOWN,
        ## Resumo Profissional

        **Engenheiro de Software Full Stack com mais de 5 anos de experiência** no desenvolvimento, arquitetura e manutenção de aplicações web escaláveis e de alto desempenho.

        Especialista em **Ruby on Rails, Node.js e TypeScript**, com sólida atuação na construção de arquiteturas backend robustas, APIs RESTful de alta disponibilidade, integrações entre sistemas e otimização de performance.

        Possuo experiência com soluções **cloud-native na AWS**, automação de processos e implementação de recursos baseados em **Inteligência Artificial e Large Language Models (LLMs)**.

        Minha atuação é orientada por boas práticas de engenharia de software, incluindo:

        - Clean Architecture
        - Test-Driven Development — TDD
        - SOLID
        - Design Patterns
        - APIs RESTful
        - Arquiteturas escaláveis
        - Integrações cloud
        - Monitoramento e otimização de performance

        Busco oportunidades como **Senior Full Stack Engineer** em empresas de alto crescimento, especialmente nos setores de **fintech, e-commerce e SaaS**, onde possa contribuir com decisões arquiteturais, liderar iniciativas técnicas complexas e desenvolver soluções modernas, confiáveis e escaláveis.
      MARKDOWN
      en: <<~MARKDOWN
        ## Professional Summary

        **Full Stack Software Engineer with over 5 years of experience** in the development, architecture, and maintenance of scalable, high-performance web applications.

        Specialist in **Ruby on Rails, Node.js, and TypeScript**, with a strong track record in building robust backend architectures, high-availability RESTful APIs, system integrations, and performance optimization.

        I have experience with **AWS cloud-native solutions**, process automation, and the implementation of features based on **Artificial Intelligence and Large Language Models (LLMs)**.

        My work is guided by software engineering best practices, including:

        - Clean Architecture
        - Test-Driven Development (TDD)
        - SOLID principles
        - Design Patterns
        - RESTful APIs
        - Scalable architectures
        - Cloud integrations
        - Performance monitoring and optimization

        I am seeking opportunities as a **Senior Full Stack Engineer** at high-growth companies—particularly in the **fintech, e-commerce, and SaaS** sectors—where I can contribute to architectural decisions, lead complex technical initiatives, and develop modern, reliable, and scalable solutions.
      MARKDOWN
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
profile.portfolio_documents.where.not(content_kind: %w[about experience skills highlights education resume]).destroy_all

resume_document = profile.portfolio_documents.find_by!(content_kind: "resume")
unless resume_document.file.attached?
  resume_document.file.attach(
    io: File.open(resume_path),
    filename: "Carlos_Henrique_Caldeira_Curriculo.pdf",
    content_type: "application/pdf"
  )
end
