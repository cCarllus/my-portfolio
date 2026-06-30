class ApplicationMailer < ActionMailer::Base
  helper ApplicationHelper

  default from: -> { ENV.fetch("MAIL_FROM", "crick.lucas+contato@gmail.com") }
  layout "mailer"
end
