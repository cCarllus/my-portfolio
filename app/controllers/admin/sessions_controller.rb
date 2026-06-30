module Admin
  class SessionsController < ApplicationController
    layout "admin"

    rate_limit to: 5,
      within: 15.minutes,
      only: :create,
      with: -> { render :new, status: :too_many_requests }

    def new
    end

    def create
      if Credentials.valid?(params[:email], params[:password])
        reset_session
        session[:admin_authenticated] = true
        redirect_to admin_root_path, notice: t("admin.sessions.signed_in")
      else
        flash.now[:alert] = t("admin.sessions.invalid")
        render :new, status: :unprocessable_content
      end
    end

    def destroy
      reset_session
      redirect_to root_path, notice: t("admin.sessions.signed_out")
    end
  end
end
