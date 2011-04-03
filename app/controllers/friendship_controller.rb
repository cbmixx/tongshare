class FriendshipController < ApplicationController
  before_filter :authenticate_user!
  
  def add_or_remove
    target_user = User.find(params[:target_user])
    friendship_to = current_user.friendship_to.find_by_to_user_id(target_user.id)
    if (friendship_to)
      friendship_to.destroy
      flash[:notice] = '同享已经知道您不(想)认识' + target_user.friendly_name
    else
      Friendship.create!(:from_user_id => current_user.id, :to_user_id => target_user.id)
      flash[:notice] = '同享已经知道您认识或想认识' + target_user.friendly_name
    end
    url = request.env["HTTP_REFERER"]
    url ||= url_for :controller => "home", :action => "index"
    redirect_to url
  end

  def show
    if (params[:type] == 'from')
      @title = 'Ta们认识或想认识你'
      @friends = current_user.friendship_from.order("created_at DESC").map{ |f| f.from_user }
    elsif (params[:type] == 'bidirectional')
      @title = 'Ta们和你互相认识'
      @friends = current_user.friendship_from.find_all_by_property(Friendship::BIDIRECTIONAL, :order => "created_at DESC").map{ |f| f.from_user }
    elsif (params[:type] == 'only_from')
      @title = 'Ta们认识或想认识你，你认识他们吗？'
      friendships = current_user.friendship_from.where('property = ?', Friendship::UNIDIRECTIONAL).order("created_at DESC").to_a
      @friends = friendships.map{ |f| f.from_user }
    end
  end

end
