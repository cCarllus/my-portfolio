require "rails_helper"

RSpec.describe Admin::PositionRecords do
  let(:profile) { create_portfolio_profile }

  it "appends and reorders records within the portfolio scope" do
    first = profile.skills.create!(name: "Ruby", category: "backend", position: 0)
    second = profile.skills.new(name: "Rails", category: "backend")

    described_class.append(second, scope: profile.skills)
    second.save!
    described_class.reorder(scope: profile.skills, ids: [ second.id, first.id ])

    expect(profile.skills.ordered.pluck(:id, :position)).to eq([
      [ second.id, 0 ],
      [ first.id, 1 ]
    ])
  end
end
