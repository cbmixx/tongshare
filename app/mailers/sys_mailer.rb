class SysMailer < ActionMailer::Base
  default :from => "rubycaltest@gmail.com"

  def reminder_email(user)
    @user = user
    mail(:to => user.email, 
         :subject => "Reminder:"
        )
  end
end
