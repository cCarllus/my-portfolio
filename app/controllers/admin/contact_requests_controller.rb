module Admin
  class ContactRequestsController < BaseController
    def index
      @contact_requests = ContactRequest.order(created_at: :desc)
    end

    def show
      @contact_request = ContactRequest.find(params[:id])
    end
  end
end
