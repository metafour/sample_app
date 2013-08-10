class Notifier < ActionMailer::Base
  default from: 'no-reply@metafour.org'

  def welcome(user)
    mail to: user.email, subject: "Sample App - Thanks For Signing Up!"
  end

end
