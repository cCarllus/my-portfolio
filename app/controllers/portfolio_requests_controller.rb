class PortfolioRequestsController < ApplicationController
  rate_limit to: 5,
    within: 1.hour,
    only: :create,
    with: -> { redirect_to root_path, alert: t("portfolio_requests.rate_limited") }

  def create
    return redirect_to(root_path) if request_params[:website].present?
    return redirect_to(new_admin_session_path) if Admin::Credentials.trigger_email?(request_params[:email])

    Portfolio::RequestPresentation.call(
      email: request_params[:email],
      contact_name: request_params[:contact_name],
      company_name: request_params[:company_name],
      job_title: request_params[:job_title],
      locale: I18n.locale.to_s,
      request_ip: request.remote_ip,
      user_agent: request.user_agent
    )

    redirect_to root_path, notice: t("portfolio_requests.queued")
  rescue ActiveRecord::RecordInvalid
    redirect_to root_path, alert: t("portfolio_requests.invalid_email")
  end

  private

  def request_params
    params.require(:contact_request).permit(
      :email,
      :contact_name,
      :company_name,
      :job_title,
      :website
    )
  end
end
