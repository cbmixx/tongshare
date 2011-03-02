class SysMailer < ActionMailer::Base
  default :from => "foo@bar.com"

  def test_email(to)
    mail(:to => to, :subject => "Test for sending email")
  end

  def reminder_email(user)
    @user = user
    mail(:to => user.email, 
         :subject => "Reminder:"
        )
  end
end
