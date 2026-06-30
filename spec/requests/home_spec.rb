require "rails_helper"

RSpec.describe "Home", type: :request do
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
    {
      en: [ "Hello, I&#39;m Carlos Henrique Caldeira (Rick)", "Work experience" ],
      es: [ "Hola, soy Carlos Henrique Caldeira (Rick)", "Experiencia" ]
    }.each do |locale, expected_content|
      get root_path(locale:)

      expect(response).to have_http_status(:ok)
      expected_content.each { |content| expect(response.body).to include(content) }
    end
  end

  it "provides language controls and real document previews" do
    get root_path

    expect(response.body).to include("aria-label=\"Selecionar idioma\"")
    expect(response.body).to include("<dialog")
    expect(response.body).to include("mais de quatro anos de experiência")
    expect(response.body).to include("Análise e Desenvolvimento de Sistemas")
    expect(response.body).to include("/documents/carlos-henrique-caldeira-curriculo.pdf")
  end
end
