module Github
  class SyncPublicRepositories
    Result = Data.define(:imported, :updated, :hidden)

    def initialize(profile:, client:)
      @profile = profile
      @client = client
    end

    def call
      repositories = client.repositories
      imported = 0
      updated = 0

      profile.transaction do
        profile.update!(github_url: client.profile_url)
        repositories.each do |repository|
          project = profile.highlights.find_or_initialize_by(github_repository_id: repository.fetch("id"))
          project.new_record? ? imported += 1 : updated += 1
          assign_repository(project, repository)
          project.save!
        end

        hidden = hide_missing_repositories(repositories)
        return Result.new(imported:, updated:, hidden:)
      end
    end

    private

    attr_reader :profile, :client

    def assign_repository(project, repository)
      name = repository.fetch("name")
      description = repository["description"].presence || ""
      project.assign_attributes(
        source: "github",
        titles: { pt: name, en: name },
        descriptions: { pt: description, en: description },
        external_url: repository.fetch("html_url"),
        primary_language: repository["language"],
        category: project.new_record? ? "project" : project.category,
        position: project.new_record? ? next_position : project.position,
        published: true,
        github_synced_at: Time.current
      )
    end

    def hide_missing_repositories(repositories)
      repository_ids = repositories.map { |repository| repository.fetch("id") }
      missing = profile.highlights.where(source: "github").where.not(github_repository_id: repository_ids)
      count = missing.where(published: true).count
      missing.update_all(published: false, github_synced_at: Time.current)
      count
    end

    def next_position
      @next_position ||= profile.highlights.maximum(:position).to_i + 1
      value = @next_position
      @next_position += 1
      value
    end
  end
end
