class AcceptanceController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    authorize! :create, Acceptance
  end

  def destroy
    authorize! :destroy, Acceptance
  end

  def deny
    acc = Acceptance.find(params[:id])
    authorize! :deny, acc
    acc.decision = false
    acc.save!

    flash[:notice] = I18n.t 'tongshare.acceptance.denied'
    if can? :read, acc.event
      redirect_to acc.event
    else
      redirect_to :root
    end
  end

  def accept
    authorize! :accept, Acceptance
  end

end
