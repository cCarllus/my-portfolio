require "rails_helper"

RSpec.describe "Home", type: :request do
  it "renders the public portfolio homepage in Portuguese by default" do
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Olá, eu sou Rick")
    expect(response.body).to include("Experiências")
    expect(response.body).to include("Meu portfólio")
  end

  it "renders the homepage in every supported secondary locale" do
    {
      en: [ "Hello, it&#39;s Rick", "Work experience" ],
      es: [ "Hola, soy Rick", "Experiencia" ]
    }.each do |locale, expected_content|
      get root_path(locale:)

      expect(response).to have_http_status(:ok)
      expected_content.each { |content| expect(response.body).to include(content) }
    end
  end
end
