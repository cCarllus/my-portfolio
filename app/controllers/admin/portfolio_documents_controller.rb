module Admin
  class PortfolioDocumentsController < BaseController
    include CrudActions

    private

    def model_class = PortfolioDocument
    def collection_path = admin_portfolio_documents_path

    def record_params
      params.require(:portfolio_document).permit(
        :published,
        :uses_resume,
        :file,
        titles: I18n.available_locales,
        bodies: I18n.available_locales
      )
    end
  end
end
