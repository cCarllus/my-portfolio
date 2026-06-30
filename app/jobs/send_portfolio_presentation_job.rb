class SendPortfolioPresentationJob < ApplicationJob
  queue_as :default

  discard_on ActiveRecord::RecordNotFound

  def perform(contact_request_id)
    Portfolio::DeliverPresentation.call(ContactRequest.find(contact_request_id))
  end
end
