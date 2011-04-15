class SearchController < ApplicationController
  include SharingsHelper
  include RegistrationsExtendedHelper
  include UsersHelper
  include EventsHelper
  before_filter :authenticate_user!

  def index
  end

  def add_members
    begin_time = Time.parse(params[:begin])
    end_time = Time.parse(params[:end])

    result = {:valid => [], :dummy => [], :new_email => [], :duplicated => [], :invalid => [], :parse_errored => []}

    items = parse_sharings_raw(params[:raw_string])

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
        end
      rescue ActiveRecord::RecordNotFound
      end
    end

    for item in items
      if item[:type].nil?
        result[:parse_errored] << item[:login_value]
        next
      end

      ui = item[:type] == :uid ? item[:uid] : UserIdentifier.find_by(item[:type], item[:login_value])
      if !ui.nil?
        begin
          name = (ui.user.user_extra.name) + (item[:login_value] ? "(#{item[:login_value]})" : "")
        rescue Exception
          name = item[:login_value]
        end
        data_entry = {:id => ui.user_id, :name => name, :conflict => []}  #do not expose user_friendly_name or attackers can enumerate 学号/姓名 pair by add sharings.

        #check time conflict
        user_instances = query_all_accepted_instance_includes_event(begin_time, end_time, ui.user_id)
        user_instances.each do |i|
          data_entry[:conflict] << friendly_time_range(i.begin, i.end)
        end

        data_entry[:name] << " 可能有空" if (data_entry[:conflict].size == 0)

        result[:valid] << data_entry
      elsif item[:type] == UserIdentifier::TYPE_EMPLOYEE_NO
        result[:dummy] << item[:login_value]
      elsif item[:type] == UserIdentifier::TYPE_EMAIL
        result[:new_email] << item[:login_value]
      else
        result[:invalid] << item[:login_value]
      end
    end

    @json = result.to_json

    respond_to do |format|
      format.js
    end
  end

  def box
    keyword = params[:keyword]
    @has_user = UserExtra.find(:first, :conditions => ['name=?', keyword]) ? 1 : 0
    @has_location = Location.find(:first, :conditions => ['name LIKE ?', "\%#{keyword}\%"]) ? 1 : 0
    @has_public_user = UserExtra.find(:first, :conditions => ['public=? AND name LIKE ?', true, "\%#{keyword}\%"]) ? 1 : 0
    @has_public_group = Group.find(:first, :conditions => ['privacy=? AND name LIKE ?', Group::PRIVACY_PUBLIC, "\%#{keyword}\%"]) ? 1 : 0
    @sum = @has_user + @has_location + @has_public_user + @has_public_group
    if (@sum == 1)
      if (@has_user > 0)
        redirect_to "/search/user/"+URI.escape(keyword)
      elsif (@has_location > 0)
        redirect_to "/search/location/"+URI.escape(keyword)
      elsif (@has_public_user > 0)
        redirect_to "/search/public_user/"+URI.escape(keyword)
      elsif (@has_public_group > 0)
        redirect_to "/search/public_group/"+URI.escape(keyword)
      end
    end
  end

  def user
    keyword = params[:keyword]
    @offset = params[:offset] ? params[:offset].to_i : 0
    @users = UserExtra.find(:all, :conditions => ['name=?', keyword], :offset => @offset, :limit => 10+1, :include => :user).map{ |ue| ue.user }
  end

  def location
    keyword = params[:keyword]
    @offset = params[:offset] ? params[:offset].to_i : 0
    @locations = Location.find(:all, :conditions => ['name LIKE ?', "\%#{keyword}\%"], :offset => @offset, :limit => 10+1).map{ |loc| loc.name }
  end

  def public_user
    keyword = params[:keyword]
    @offset = params[:offset] ? params[:offset].to_i : 0
    @public_users = UserExtra.find(:all, :conditions => ['public=? AND name LIKE ?', true, "\%#{keyword}\%"], :offset => @offset, :limit => 10+1, :include => :user).map{ |ue| ue.user }
  end

  def public_group
    keyword = params[:keyword]
    @offset = params[:offset] ? params[:offset].to_i : 0
    @public_groups = Group.find(:all, :conditions => ['privacy=? AND name LIKE ?', Group::PRIVACY_PUBLIC, "\%#{keyword}\%"], :offset => @offset, :limit => 10+1)
  end

end
