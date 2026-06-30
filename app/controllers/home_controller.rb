class HomeController < ApplicationController
  def index
    profile = PortfolioProfile.includes(
      :skills,
      :experiences,
      :highlights,
      :educations,
      :portfolio_documents,
      avatar_attachment: :blob,
      resume_attachment: :blob
    ).first

    @portfolio = PortfolioPresenter.new(profile) if profile
  end
end
