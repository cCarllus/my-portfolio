module Admin
  class EmailTemplatesController < BaseController
    before_action :set_profile

    def edit
    end

    def update
      if @profile.update(email_params)
        redirect_to edit_admin_email_template_path, notice: t("admin.notices.updated")
      else
        render :edit, status: :unprocessable_content
      end
    end

    private

    def set_profile
      @profile = portfolio_profile
    end

    def email_params
      params.require(:portfolio_profile).permit(
        :resume,
        email_subjects: I18n.available_locales,
        email_bodies: I18n.available_locales
      )
    end
  end
end
