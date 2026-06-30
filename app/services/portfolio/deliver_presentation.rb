module Portfolio
  class DeliverPresentation
    def self.call(contact_request)
      PortfolioMailer.with(contact_request:).presentation.deliver_now
      contact_request.update!(status: :sent, sent_at: Time.current, error_message: nil)
    rescue StandardError => error
      contact_request.update!(status: :failed, error_message: error.message)
      raise
    end
  end
end
