module Admin
  class ProfilesController < BaseController
    before_action :set_profile

    def edit
    end

    def update
      if @profile.update(profile_params)
        redirect_to edit_admin_profile_path, notice: t("admin.notices.updated")
      else
        render :edit, status: :unprocessable_content
      end
    end

    private

    def set_profile
      @profile = portfolio_profile
    end

    def profile_params
      params.require(:portfolio_profile).permit(
        :full_name,
        :nickname,
        :contact_email,
        :phone,
        :linkedin_url,
        :github_url,
        :avatar,
        :avatar_url,
        roles: I18n.available_locales,
        locations: I18n.available_locales,
        philosophies: I18n.available_locales
      )
    end
  end
end
