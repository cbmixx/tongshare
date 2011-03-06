class AcceptanceController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    authorize! :create, Acceptance
  end

  def destroy
    authorize! :destroy, Acceptance
  end

  def accept
    sharing = Sharing.find(params[:id], :include => [:event])
    event = sharing.event
    acc = Acceptance.new(:user_id => current_user.id, :event_id => event.id, :decision => true)
    authorize! :accept, acc
    acc.save!

    flash[:notice] = I18n.t 'tongshare.acceptance.accepted', :name => event.name
    redirect_to event
  end

  def deny
    sharing = Sharing.find(params[:id], :include => [:event])
    event = sharing.event
    acc = Acceptance.new(:user_id => current_user.id, :event_id => event.id, :decision => false)
    authorize! :deny, acc
    acc.save!

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

    flash[:notice] = I18n.t 'tongshare.acceptance.exited', :name => acc.event.name
    if can? :read, acc.event
      redirect_to acc.event
    else
      redirect_to :root
    end
  end
end
