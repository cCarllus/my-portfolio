require "rails_helper"

RSpec.describe "Home", type: :request do
  before { create_portfolio_content }

  it "renders the public portfolio homepage in Portuguese by default" do
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Olá, eu sou Carlos Henrique Caldeira (Rick)")
    expect(response.body).to include("Experiências")
    expect(response.body).to include("Meu portfólio")
    expect(response.body).to include("carlos-henrique-caldeira-")
    expect(response.body).to include("2025 — 2026")
    expect(response.body).to include("Até 40% menos latência")
    expect(response.body).to include("class</span> <span class=\"code-class\">CarlosCaldeira")
    expect(response.body).to include("@stack")
    expect(response.body).to include("$PROGRAM_NAME")
  end

  it "renders the homepage in every supported secondary locale" do
    get root_path(locale: :en)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Hello, I&#39;m Carlos Henrique Caldeira (Rick)")
    expect(response.body).to include("Work experience")
    expect(response.body).not_to include(">ES<")
  end

  it "provides language controls and real document previews" do
    get root_path

    expect(response.body).to include("aria-label=\"Selecionar idioma\"")
    expect(response.body).to include("<dialog")
    expect(response.body).to include("mais de quatro anos de experiência")
    expect(response.body).to include("Análise e Desenvolvimento de Sistemas")
    expect(response.body).to include("/rails/active_storage/blobs")
  end

  it "limits the animated skill preview and exposes every skill in a modal" do
    profile = PortfolioProfile.current
    4.times do |index|
      profile.skills.create!(name: "Skill extra #{index + 1}", position: index + 5, published: true)
    end

    get root_path

    expect(response.body).to include("Skill extra 4")
    expect(response.body).to include("skills-marquee")
    expect(response.body).to include("skills-modal")
    expect(response.body).to include("Ver todas (9)")
  end

  it "renders generated files directly from experience, skill, highlight and education data" do
    profile = PortfolioProfile.current
    experience = profile.experiences.first
    experience.update!(
      company: "Empresa sincronizada",
      summaries: { pt: "**Arquitetura** de APIs críticas." }
    )

    get root_path
    document = Nokogiri::HTML(response.body)

    expect(document.at_css(".document-panel--experience").text).to include("Empresa sincronizada")
    expect(document.at_css(".document-panel--experience").to_html).to include("<strong>Arquitetura</strong>")
    expect(document.at_css(".document-panel--skills").text).to include("Ruby on Rails")
    expect(document.at_css(".document-panel--highlights").text).to include("40%")
    expect(document.at_css(".document-panel--education").text).to include("FATEC-SP")
  end
end
