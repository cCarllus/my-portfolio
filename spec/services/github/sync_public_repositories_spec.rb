require "rails_helper"

RSpec.describe Github::SyncPublicRepositories do
  FakeClient = Struct.new(:profile_url, :repositories)

  let(:profile) { create_portfolio_profile }
  let(:repositories) do
    [
      {
        "id" => 123,
        "name" => "public-project",
        "description" => "A public project",
        "html_url" => "https://github.com/cCarllus/public-project",
        "language" => "Ruby"
      }
    ]
  end

  it "imports public repositories and updates the GitHub profile URL" do
    result = described_class.new(
      profile:,
      client: FakeClient.new("https://github.com/cCarllus", repositories)
    ).call

    project = profile.highlights.find_by!(github_repository_id: 123)
    expect(result).to have_attributes(imported: 1, updated: 0, hidden: 0)
    expect(profile.reload.github_url).to eq("https://github.com/cCarllus")
    expect(project).to have_attributes(
      source: "github",
      external_url: "https://github.com/cCarllus/public-project",
      primary_language: "Ruby",
      category: "project",
      published: true
    )
    expect(project.titles).to include("pt" => "public-project", "en" => "public-project")
    expect(project.descriptions).to include("pt" => "A public project")
  end

  it "updates known repositories and hides repositories no longer returned" do
    kept = profile.highlights.create!(
      source: "github",
      github_repository_id: 123,
      titles: { pt: "Old name" },
      descriptions: { pt: "Old description" },
      category: "highlight",
      position: 0
    )
    missing = profile.highlights.create!(
      source: "github",
      github_repository_id: 999,
      titles: { pt: "Private now" },
      position: 1
    )

    result = described_class.new(
      profile:,
      client: FakeClient.new("https://github.com/cCarllus", repositories)
    ).call

    expect(result).to have_attributes(imported: 0, updated: 1, hidden: 1)
    expect(kept.reload.localized(:titles, :pt)).to eq("public-project")
    expect(kept.category).to eq("highlight")
    expect(missing.reload).not_to be_published
  end
end
