class AcceptanceController < ApplicationController
  before_filter :authenticate_user!

  def right_email?
    email = params[:email]
    return true if email.nil?
    return current_user.email == email
  end
  
  def create
    authorize! :create, Acceptance
  end

  def destroy
    authorize! :destroy, Acceptance
  end

  def accept
    sharing = Sharing.find(params[:id], :include => [:event])
    event = sharing.event

    if (!right_email?)
      flash[:alert] = I18n.t 'tongshare.sharing.wrong_email'
      if can? :read, event
        redirect_to event
      else
        redirect_to :root
      end
      return
    end

    acc = Acceptance.find_or_create_by_user_id_and_event_id(:user_id => current_user.id, :event_id => event.id)
    authorize! :accept, acc
    acc.decision = true
    acc.save!

    mail = SysMailer.accept_or_deny_sharing_email(sharing, acc)
    mail.deliver if !mail.nil?
    flash[:notice] = I18n.t 'tongshare.acceptance.accepted', :name => event.name
    redirect_to event
  end

  def deny
    sharing = Sharing.find(params[:id], :include => [:event])
    event = sharing.event

    if (!right_email?)
      flash[:alert] = I18n.t 'tongshare.sharing.wrong_email'
      if can? :read, event
        redirect_to event
      else
        redirect_to :root
      end
      return
    end

    acc = Acceptance.find_or_create_by_user_id_and_event_id(:user_id => current_user.id, :event_id => event.id)
    authorize! :deny, acc
    acc.decision = false
    acc.save!

    mail = SysMailer.accept_or_deny_sharing_email(sharing, acc)
    mail.deliver if !mail.nil?
    flash[:notice] = I18n.t 'tongshare.acceptance.denied', :name => event.name
    if can? :read, event
      redirect_to event
    else
      redirect_to :root
    end
  end

  def exit
    acc = Acceptance.find(params[:id])
    authorize! :exit, acc
    acc.decision = false
    acc.save!

#    mail = SysMailer.accept_or_deny_sharing_email(acc)
#    mail.deliver if !mail.nil?
    flash[:notice] = I18n.t 'tongshare.acceptance.exited', :name => acc.event.name
    if can? :read, acc.event
      redirect_to acc.event
    else
      redirect_to :root
    end
  end
end
