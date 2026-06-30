module Admin
  class HighlightsController < BaseController
    include CrudActions

    private

    def model_class = Highlight
    def collection_path = admin_highlights_path

    def record_params
      params.require(:highlight).permit(
        :metric,
        :published,
        titles: I18n.available_locales,
        descriptions: I18n.available_locales
      )
    end
  end
end
