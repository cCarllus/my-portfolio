require "rails_helper"

RSpec.describe "Admin pages", type: :request do
  before do
    allow_any_instance_of(AdminPolicy).to receive(:authorized?).and_return(true)
    profile = create_portfolio_content
    profile.highlights.create!(titles: { pt: "Destaque" }, descriptions: { pt: "Descrição" }, position: 1)
    ContactRequest.create!(email: "recrutador@example.com", locale: "pt", status: :sent)
  end

  it "renders every management surface" do
    paths = [
      admin_root_path,
      edit_admin_profile_path,
      admin_skills_path,
      admin_experiences_path,
      admin_highlights_path,
      admin_educations_path,
      admin_portfolio_documents_path,
      edit_admin_email_template_path,
      edit_admin_map_path,
      admin_contact_requests_path
    ]

    editable_records = [
      [ new_admin_skill_path, edit_admin_skill_path(Skill.first) ],
      [ new_admin_experience_path, edit_admin_experience_path(Experience.first) ],
      [ new_admin_highlight_path, edit_admin_highlight_path(Highlight.first) ],
      [ new_admin_education_path, edit_admin_education_path(Education.first) ],
      [ new_admin_portfolio_document_path, edit_admin_portfolio_document_path(PortfolioDocument.first) ]
    ]
    paths.concat(editable_records.flatten)

    paths.each do |path|
      get path
      expect(response).to have_http_status(:ok), "expected #{path} to render"
    end
  end

  it "shows one visible editor per translated field with only Portuguese and English" do
    get edit_admin_profile_path
    document = Nokogiri::HTML(response.body)

    expect(document.css('[data-localized-field-target="editor"]').size).to eq(3)
    expect(document.css('[data-localized-field-target="stored"]').size).to eq(6)
    expect(response.body).not_to include("Espanhol")
  end

  it "does not ask for manual position or color on skill forms" do
    get new_admin_skill_path
    document = Nokogiri::HTML(response.body)

    expect(document.at_css('input[name="skill[position]"]')).to be_nil
    expect(document.at_css('input[name="skill[color]"]')).to be_nil
  end
end
