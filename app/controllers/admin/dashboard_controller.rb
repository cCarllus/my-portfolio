module Admin
  class DashboardController < BaseController
    def index
      @counts = {
        skills: portfolio_profile.skills.count,
        experiences: portfolio_profile.experiences.count,
        documents: portfolio_profile.portfolio_documents.count,
        requests: ContactRequest.count
      }
      @recent_requests = ContactRequest.order(created_at: :desc).limit(5)
    end
  end
end
