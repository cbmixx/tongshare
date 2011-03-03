class EventsController < ApplicationController
  include EventsHelper
  include UsersHelper
  include AuthHelper
  include CurriculumHelper
  include SiteConnectHelper

  before_filter :authenticate_user!

  # GET /events
  # GET /events.xml
  def index
    #@events = Event.find_all_by_creator_id current_user.id
    authorize! :index, Event

    params[:range] = "next" unless ["next", "day", "week"].include?(params[:range])
    params[:offset] ||= 0
    params[:limit] ||= 10
    @range = params[:range].to_sym
    @offset = params[:offset].to_i
    @limit = params[:limit].to_i

    if @range == :next
      @instances = query_next_accepted_instance_includes_event(Time.now, @limit + 1, current_user.id, @offset)
      if @instances.count == @limit + 1
        #not the last page
        @instances.delete_at(@instances.count - 1)
        @is_last_page = false
      else
        @is_last_page = true
      end
      @limit = @instances.count
    else
      case @range
        when :day
          from = Date.today + @offset.days
          to = Date.today + @offset.days + 1.days
        when :week
          from = Date.today.beginning_of_week + @offset.weeks
          to = Date.today.beginning_of_week + @offset.weeks + 1.weeks
      end

      #TODO: this month, all(events)

      #logger.debug from.to_time.to_s
      #logger.debug to.to_time.to_s

      @instances = query_all_accepted_instance_includes_event(from.to_time, to.to_time)
    end

    #check confirmation for employee_no
    user_id_rec = current_user.user_identifier.find(:first,
      :conditions => ["login_type = ?", UserIdentifier::TYPE_EMPLOYEE_NO])

    if !user_id_rec.nil?
      @not_confirmed = !user_id_rec.confirmed
      username = user_id_rec.login_value
      username = username.delete(company_domain(current_user) + ".")
      @auth_path = auth_path(username, root_url)
    end

    #sharing
    @invited_user_sharings = query_sharing_event

    @curriculum_empty = curriculum_empty?(current_user)

    respond_to do |format|
      format.html # index.html.erb
      #format.xml  { render :xml => @instances }
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    @event = Event.find(params[:id])
    @instance = params[:inst].blank? ? nil : Instance.find(params[:inst])

    authorize! :show, @event

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    @event = Event.new

    #automatically set time
    range = params[:range].blank? ? :day : params[:range].to_sym
    offset = params[:offset].blank? ? 0 : params[:offset].to_i

    case range
    when :next
        @event.begin = Time.now
    when :day
        @event.begin = Time.now + offset.days
    when :week
        @event.begin = Time.now + offset.weeks
    end

    @event.end = @event.begin + 30.minutes
    time_ruby2selector(@event)

    @event.rrule_days = [Date.today.wday]
    @event.rrule_count = 16  #TODO: how to set default value?

    @event.creator_id = current_user.id
    authorize! :new, @event

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    authorize! :edit, @event
    
    time_ruby2selector(@event)
  end

  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event])
    time_selector2ruby(@event)

    @event.creator_id = current_user.id
    authorize! :create, @event
    
    ret = @event.save
    respond_to do |format|
      if ret
        format.html { redirect_to(@event, :notice => I18n.t('tongshare.event.created', :name => @event.name)) }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    @event = Event.find(params[:id])
    authorize! :update, @event
    
    time_selector2ruby(@event)
    
    ret = @event.update_attributes(params[:event])
    
    respond_to do |format|
      if ret
        format.html { redirect_to(@event, :notice => I18n.t('tongshare.event.updated', :name => @event.name)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event = Event.find(params[:id])
    
    authorize! :destroy, @event

    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
      format.xml  { head :ok }
    end
  end



end

