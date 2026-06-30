require "rails_helper"

RSpec.describe "Admin projects and highlights", type: :request do
  before do
    allow_any_instance_of(AdminPolicy).to receive(:authorized?).and_return(true)
    @profile = create_portfolio_profile
  end

  it "creates a manual project with category, link and Markdown content" do
    post admin_highlights_path, params: {
      highlight: {
        external_url: "https://example.com/project",
        category: "highlight",
        published: "1",
        titles: { pt: "Projeto manual", en: "Manual project" },
        descriptions: { pt: "**Impacto** com [documentação](https://example.com/docs)." }
      }
    }

    project = @profile.highlights.find_by!(source: "manual")
    expect(response).to redirect_to(admin_highlights_path)
    expect(project).to have_attributes(category: "highlight", external_url: "https://example.com/project")
    expect(project.category_color).to match(/\A#[0-9a-f]{6}\z/i)
  end

  it "synchronizes the configured public GitHub profile" do
    result = Github::SyncPublicRepositories::Result.new(imported: 2, updated: 1, hidden: 0)
    service = instance_double(Github::SyncPublicRepositories, call: result)
    allow(Github::PublicRepositoriesClient).to receive(:new)
      .with(profile_url: "https://github.com/cCarllus")
      .and_return(:client)
    allow(Github::SyncPublicRepositories).to receive(:new)
      .with(profile: @profile, client: :client)
      .and_return(service)

    post sync_github_admin_highlights_path, params: { github_url: "https://github.com/cCarllus" }

    expect(response).to redirect_to(admin_highlights_path)
    follow_redirect!
    expect(response.body).to include("2")
    expect(response.body).to include("1")
  end
end
