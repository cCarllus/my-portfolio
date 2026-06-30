require "rails_helper"

RSpec.describe SyncGithubProjectsJob do
  it "synchronizes the configured profile" do
    profile = create_portfolio_profile
    profile.update!(github_url: "https://github.com/cCarllus")
    client = instance_double(Github::PublicRepositoriesClient)
    service = instance_double(Github::SyncPublicRepositories, call: true)
    allow(Github::PublicRepositoriesClient).to receive(:new)
      .with(profile_url: profile.github_url)
      .and_return(client)
    allow(Github::SyncPublicRepositories).to receive(:new)
      .with(profile:, client:)
      .and_return(service)

    described_class.perform_now(profile.id)

    expect(service).to have_received(:call)
  end
end
