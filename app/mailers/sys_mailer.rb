class SysMailer < ActionMailer::Base
  default :from => "同享日程 <no_reply@tongshare.com>"

  def test_email(to)
    mail(:to => to, :subject => "Test for sending email")
  end

  def reminder_email(user)
    @user = user
    mail(:to => user.email, 
         :subject => "Reminder:"
        )
  end
  
  def user_sharing_request_email(user_sharing)
    @user = User.find(user_sharing.user_id)
    @shared_from = User.find(user_sharing.sharing.shared_from)
    @user_sharing = user_sharing

    mail(:to => @user.email,
         :subject => I18n.t("tongshare.sharing.email.subject", :user_name => @shared_from.friendly_name)
    )   
  end

end
