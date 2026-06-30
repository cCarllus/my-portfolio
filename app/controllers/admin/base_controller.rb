module Admin
  class BaseController < ApplicationController
    layout "admin"

    before_action :require_admin
    helper_method :portfolio_profile

    private

    def require_admin
      return if AdminPolicy.new(session).authorized?

      redirect_to new_admin_session_path, alert: t("admin.sessions.required")
    end

    def portfolio_profile
      @portfolio_profile ||= PortfolioProfile.current || PortfolioProfile.new
    end
  end
end
