class SharingsController < ApplicationController
  include SharingsHelper
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
    result = {:valid => [], :dummy => [], :invalid => [], :parse_errored => []}

    items = parse_sharings_raw(params[:raw_string])
    for item in items
      if item[:type].nil?
        result[:parse_errored] << item[:login_value]
        next
      end

      ui = UserIdentifier.find_by(item[:type], item[:login_value])
      if !ui.nil?
        result[:valid] << {:id => ui.user_id, :name => item[:login_value]}  #do not expose user_friendly_name or attackers can enumerate 学号/姓名 pair by add sharings.
      elsif item[:type] == UserIdentifier::TYPE_EMPLOYEE_NO
        result[:dummy] << item[:login_value]
      else
        result[:invalid] << item[:login_value]
      end
    end

    @json = result.to_json

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
