module Portfolio
  class RequestPresentation
    def self.call(**attributes)
      request = ContactRequest.create!(attributes)
      SendPortfolioPresentationJob.perform_later(request.id)
      request
    end
  end
end
