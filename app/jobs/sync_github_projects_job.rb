class SyncGithubProjectsJob < ApplicationJob
  queue_as :default

  retry_on Github::PublicRepositoriesClient::Error, wait: 15.minutes, attempts: 3
  discard_on ActiveRecord::RecordNotFound

  def perform(profile_id)
    profile = PortfolioProfile.find(profile_id)
    return if profile.github_url.blank?

    client = Github::PublicRepositoriesClient.new(profile_url: profile.github_url)
    Github::SyncPublicRepositories.new(profile:, client:).call
  end
end
