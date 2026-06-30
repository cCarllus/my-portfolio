module Admin
  class HighlightsController < BaseController
    include CrudActions

    def sync_github
      client = Github::PublicRepositoriesClient.new(profile_url: params.require(:github_url))
      result = Github::SyncPublicRepositories.new(profile: portfolio_profile, client:).call

      redirect_to admin_highlights_path, notice: t(
        "admin.highlights.github.synced",
        imported: result.imported,
        updated: result.updated,
        hidden: result.hidden
      )
    rescue Github::PublicRepositoriesClient::Error, ActiveRecord::RecordInvalid => error
      redirect_to admin_highlights_path, alert: error.message
    end

    private

    def model_class = Highlight
    def collection_path = admin_highlights_path

    def record_params
      params.require(:highlight).permit(
        :metric,
        :external_url,
        :category,
        :published,
        titles: I18n.available_locales,
        descriptions: I18n.available_locales
      )
    end
  end
end
