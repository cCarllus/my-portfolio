require "rails_helper"

RSpec.describe "Admin skills", type: :request do
  before do
    allow_any_instance_of(AdminPolicy).to receive(:authorized?).and_return(true)
    @profile = create_portfolio_profile
  end

  it "creates a persisted skill" do
    post admin_skills_path, params: {
      skill: {
        portfolio_profile_id: @profile.id,
        name: "Elasticsearch",
        category: "backend",
        featured: "1",
        published: "1"
      }
    }

    expect(response).to redirect_to(admin_skills_path)
    skill = Skill.find_by!(name: "Elasticsearch")
    expect(skill.color).to match(/\A#[0-9a-f]{6}\z/)
    expect(skill.position).to eq(0)
  end

  it "persists the order received from drag and drop" do
    first = @profile.skills.create!(name: "Ruby", category: "backend", position: 0)
    second = @profile.skills.create!(name: "Rails", category: "backend", position: 1)

    patch reorder_admin_skills_path, params: { ids: [ second.id, first.id ] }, as: :json

    expect(response).to have_http_status(:no_content)
    expect(@profile.skills.ordered.pluck(:id)).to eq([ second.id, first.id ])
  end
end
