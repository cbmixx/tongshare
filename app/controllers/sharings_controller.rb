class SharingsController < ApplicationController

  before_filter :authenticate_user!

  def index
    authorize! :index, Sharing
  end

  def show
    @sharing = Sharing.find(params[:id])
    authorize! :show, @sharing

    respond_to do |format|
      format.html
    end
  end

  def add_members
    logger.debug params[:raw_string]
    respond_to do |format|
      format.js
    end
  end

  def new
    @sharing = Sharing.new
    @sharing.shared_from = current_user.id
    @sharing.event_id = params[:event_id]
    authorize! :new, @sharing

    respond_to do |format|
      format.html
    end
  end

  def create
    @sharing = Sharing.new(params[:sharing])
    @sharing.shared_from = current_user.id
    @sharing.event_id = params[:event_id]
    authorize! :new, @sharing

    ret = @sharing.save
    respond_to do |format|
      if ret
        format.html { redirect_to(@sharing.event, :notice => I18n.t('tongshare.sharing.created', :name => @sharing.event.name)) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def edit
    authorize! :edit, Sharing
  end

  def update
    authorize! :update, Sharing
  end

  def destroy
    authorize! :destroy, Sharing
  end

end
