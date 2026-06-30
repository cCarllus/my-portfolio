module Admin
  class EducationsController < BaseController
    include CrudActions

    private

    def model_class = Education
    def collection_path = admin_educations_path

    def record_params
      params.require(:education).permit(
        :published,
        courses: I18n.available_locales,
        institutions: I18n.available_locales,
        statuses: I18n.available_locales
      )
    end
  end
end
