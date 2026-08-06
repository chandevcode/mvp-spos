class UserMailer < ApplicationMailer
  def credentials_email(user, password)
    @user = user
    @password = password
    mail(to: @user.email, subject: "Your account credentials for #{tenant_name}")
  end

  def registration_success(user, subscription_payment)
    @user = user
    @tenant = user.tenant
    @subscription = subscription_payment
    mail(to: @user.email, subject: "Welcome to #{@tenant.name} — Registration Complete!")
  end

  private

  def tenant_name
    @user.tenant&.name || "SPOS"
  end
end
