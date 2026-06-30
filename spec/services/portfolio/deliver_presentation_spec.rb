require "rails_helper"

RSpec.describe Portfolio::DeliverPresentation do
  before do
    ActionMailer::Base.deliveries.clear
    profile = create_portfolio_profile
    profile.resume.attach(
      io: StringIO.new("%PDF-1.4 test resume"),
      filename: "curriculo.pdf",
      content_type: "application/pdf"
    )
  end

  it "delivers the localized presentation with the resume attached" do
    request = ContactRequest.create!(email: "visitor@example.com", locale: "pt")

    described_class.call(request)

    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq([ "visitor@example.com" ])
    expect(mail.subject).to eq("Apresentação profissional")
    expect(mail.attachments.map(&:filename)).to include("curriculo.pdf")
    expect(request.reload).to be_sent
  end
end
