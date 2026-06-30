module Admin
  class MapsController < BaseController
    before_action :set_profile

    def edit
    end

    def update
      if @profile.update(map_params)
        redirect_to edit_admin_map_path, notice: t("admin.notices.updated")
      else
        render :edit, status: :unprocessable_content
      end
    end

    private

    def set_profile
      @profile = portfolio_profile
    end

    def map_params
      params.require(:portfolio_profile).permit(
        :map_x_percent,
        :map_y_percent,
        map_labels: I18n.available_locales
      )
    end
  end
end
