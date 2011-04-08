class GreetingController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    target_user = User.find(params[:target_user])
    event_id = params[:event_id].to_i
    Greeting.create!(:from_user_id => current_user.id, :to_user_id => target_user.id, :event_id => event_id)
    flash[:notice] = '操作成功'
    url = request.env["HTTP_REFERER"]
    url ||= url_for :controller => "home", :action => "index"
    redirect_to url
  end

  def index
    @offset = params[:offset] ? params[:offset].to_i : 0
    @greetings = current_user.greeting_from.order("created_at DESC").offset(@offset).limit(11).to_a
    @has_previous = (@offset > 0)
    @has_next = (@greetings.count > 10)
  end

end
