module Admin
  class ExperiencesController < BaseController
    include CrudActions

    private

    def model_class = Experience
    def collection_path = admin_experiences_path

    def record_params
      params.require(:experience).permit(
        :company,
        :period,
        :published,
        roles: I18n.available_locales,
        locations: I18n.available_locales,
        summaries: I18n.available_locales
      )
    end
  end
end
