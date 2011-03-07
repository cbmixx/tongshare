class SysMailer < ActionMailer::Base
  include RegistrationsExtendedHelper
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
    if !nil_email_alias?(@user.email)
      headers = {:to => @user.email,
                 :subject => I18n.t("tongshare.sharing.email.subject", :user_name => @shared_from.friendly_name)}
      headers[:reply_to] = @shared_from.email if !nil_email_alias?(@shared_from.email)
      mail(headers)
    else
      nil
    end
  end

  def accept_or_deny_sharing_email(sharing, acceptance)
    @acceptance = acceptance
    @sharing = sharing
    @user = User.find(sharing.shared_from)

    if !nil_email_alias?(@user.email)
      headers = {:to => @user.email}
      if acceptance.decision == Acceptance::DECISION_ACCEPTED
        headers[:subject] = I18n.t("tongshare.acceptance.email.accepted_subject", :name => @user.friendly_name)
      elsif acceptance.decision == Acceptance::DECISION_DENY
        headers[:subject] = I18n.t("tongshare.acceptance.email.denied_subject", :name => @user.friendly_name)
      else
        return nil
      end
      mail(headers)
    end
  end

end
