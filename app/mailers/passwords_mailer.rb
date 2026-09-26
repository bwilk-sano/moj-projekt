class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: "Zresetuj swoje hasło", to: user.email_address
  end
end
