class SharingsController < ApplicationController
  include SharingsHelper
  include RegistrationsExtendedHelper
  include UsersHelper
  include EventsHelper
  include GroupsHelper
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
    event = Event.find(params[:event_id])
    result = {:valid => [], :dummy => [], :new_email => [], :duplicated => [], :invalid => [], :parse_errored => [], :public_groups => [],
      :edit_event_path => edit_event_path(event),
      :recurring => event.recurring?,
      :empty => params[:raw_string].blank?  #I don't know how to validate a remote form on client, so I check it here. by Wander
      }

    items = parse_sharings_raw(params[:raw_string])

    public_groups = []

    if (params[:friend_id] && !params[:friend_id].blank?)
      begin
        friend = User.find(params[:friend_id].to_i)
        uid = friend.user_identifier.first
        items << {:type => :uid, :uid => uid}
      rescue ActiveRecord::RecordNotFound
      end
    end

    if (params[:group_id] && !params[:group_id].blank?)
      begin
        group = Group.find(params[:group_id].to_i)
        if (group.privacy == Group::PRIVACY_PRIVATE) # Only private groups can be invited(public group recommendation is not supported yet)
          for membership in group.membership
            user = membership.user
            uid = user.user_identifier.first
            if (uid.login_type == UserIdentifier::TYPE_EMPLOYEE_NO_DUMMY)
              items << {:type => UserIdentifier::TYPE_EMPLOYEE_NO, :login_value => uid.login_value.match(/\d+$/)[0]}
            elsif (uid.login_type == UserIdentifier::TYPE_EMAIL_DUMMY)
              items << {:type => UserIdentifier::TYPE_EMAIL, :login_value => uid.login_value}
            else
              items << {:type => :uid, :uid => uid}
            end
          end
        elsif (group.privacy == Group::PRIVACY_PUBLIC)
          public_groups << group
        end
      rescue ActiveRecord::RecordNotFound
      end
    end

    for public_group in public_groups
      data_entry = {:id => public_group.id, :name => public_group.name, :conflict => []}
      result[:public_groups] << data_entry
    end

    for item in items
      if item[:type].nil?
        result[:parse_errored] << item[:login_value]
        next
      end

      ui = item[:type] == :uid ? item[:uid] : UserIdentifier.find_by(item[:type], item[:login_value])
      if !ui.nil?
        data_entry = {:id => ui.user_id, :name => (item[:login_value] ? item[:login_value] : ui.user.user_extra.name), :conflict => []}  #do not expose user_friendly_name or attackers can enumerate 学号/姓名 pair by add sharings.

        #check time conflict
        user_instances = query_all_accepted_instance_includes_event(event.begin, event.end, ui.user_id)
        user_instances.each do |i|
          data_entry[:conflict] << friendly_time_range(i.begin, i.end)
        end
        
        result[:valid] << data_entry
      elsif item[:type] == UserIdentifier::TYPE_EMPLOYEE_NO
        result[:dummy] << item[:login_value]
      elsif item[:type] == UserIdentifier::TYPE_EMAIL
        result[:new_email] << item[:login_value]
      else
        result[:invalid] << item[:login_value]
      end
    end

    #filter duplicated
    ids = result[:valid].collect {|i| i[:id]}
    duplicated = find_duplicated_sharing(current_user.id, params[:event_id], ids).to_set

    result[:valid].uniq!

    duplicated_entries = result[:valid].select {|i| duplicated.include?(i[:id])}
    result[:duplicated].concat(duplicated_entries.collect{|i| i[:name]})
    result[:valid].delete_if {|i| duplicated.include?(i[:id])}


    @json = result.to_json

    respond_to do |format|
      format.js
    end
  end

  def new
    @event = Event.find(params[:event_id])  
    @sharing = Sharing.new
    @sharing.shared_from = current_user.id
    @sharing.event_id = params[:event_id]
    @friendly_time_range = friendly_time_range(@event.begin, @event.end)
    authorize! :new, @sharing

    @managed_groups = current_user.membership.where(:power => Membership::POWER_MANAGER).map{ |ms| ms.group }

    respond_to do |format|
      format.html
    end
  end

  def create
    #create a dummy sharing for permission check
    sharing = Sharing.new(params[:sharing])
    sharing.shared_from = current_user.id
    authorize! :create, sharing

    members = []
    #prepare dummy users
    if !params[:dummy].nil?
      params[:dummy].each do |employee_no|
        dummy = check_or_create_dummy_user(employee_no, company_domain)
        #if an illegal employee_no is submitted in params[:dummy], check_or_create_dummy_user will raise exceptions since it calls User.save! and the value won't pass validation.
        members << dummy.id
      end
    end
    if !params[:new_email].nil?
      params[:new_email].each do |new_email|
        dummy = check_or_create_general_dummy_user(UserIdentifier::TYPE_EMAIL, UserIdentifier::TYPE_EMAIL_DUMMY, new_email)
        #if an illegal employee_no is submitted in params[:dummy], check_or_create_dummy_user will raise exceptions since it calls User.save! and the value won't pass validation.
        members << dummy.id
      end
    end

    #add normal users
    if !params[:members].nil?
      params[:members].each do |id|
        members << id.to_i
      end
    end

    if (params[:group_name] && !params[:group_name].blank?)
      group = query_or_create_group_via_name_and_creator_id(params[:group_name], current_user.id)
      group_members = members.map do |member_id|
        {:user_id => member_id, :power => Membership::POWER_MEMBER}
      end
      group.set_members(group_members)
      group.save!
    end

    groups = []
    if (params[:public_groups])
      for group_id in params[:public_groups] do
        g = Group.find(group_id)
        next if g.nil? || g.privacy != Group::PRIVACY_PUBLIC
        groups << g
      end
    end

    mail_count = 0;

    @event = Event.find(sharing.event_id)
    ret = @event.add_sharing(current_user.id, sharing.extra_info, members, UserSharing::PRIORITY_INVITE, groups)
    if ret
      sharing = @event.sharings.last
      sharing.user_sharings.each do |us|
        if (us.user.has_valid_email)
          mail_count += 1;
          mail = SysMailer.user_sharing_request_email(us)
          mail.deliver if !mail.nil?
        end
      end

      #new email
      if (params[:new_email])
        for new_email in params[:new_email]
          mail_count += 1;
          SysMailer.user_sharing_request_new_email(sharing, new_email).deliver
        end
      end
    end
    #ret = @sharing.save
    respond_to do |format|
      if ret
        note = ''
        if (groups.count > 0)
          note = I18n.t('tongshare.sharing.public_group_recommended', :name => @event.name, :public_group_count => groups.count)
          @event.set_public # Events become public whenever they have been recommended to a public group
        end
        format.html { redirect_to(@event, :notice => note + I18n.t('tongshare.sharing.created', :name => @event.name,
              :count => members.count, :mail_count => mail_count)) }
      else
        #format.html { render :action => "new" } #TODO: is it necessary to restore previous data? I guess there won't be validation errors unless attackers XXOO
        format.html do
          redirect_to( {:controller=>'sharings', :action=>'new', :event_id => @event.id}, :alert => I18n.t('tongshare.sharing.failed', :name => @event.name))
        end
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
