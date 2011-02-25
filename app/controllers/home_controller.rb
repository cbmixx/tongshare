#by Wander
#home for the whole site. Currently it is used for testing

class HomeController < ApplicationController
  def index

    logger.debug "UserAgent: " + request.env["HTTP_USER_AGENT"]

    added_params = {}

    if user_signed_in?
      if (!session[:bookmark_free] || true)
        session[:bookmark_free] = true # show bookmark note only once
        if (params[:mark] &&
              (bookmark = Bookmark.find_by_user_id_and_mark(current_user.id, params[:mark])))
          added_notice = "请将此页面加为书签，以免去不断登录的麻烦(对于那些不能用cookie自动登录的浏览器)"
          bookmark.increase_count
          added_params[:mark] = params[:mark]
          added_params[:auth_token] = params[:auth_token]
        else
          rand_mark = SecureRandom.hex(16)
          Bookmark.add_new_mark(current_user.id, rand_mark)
          flash[:notice] = notice
          flash[:alert] = alert
          redirect_to sprintf("/?mark=%s&auth_token=%s", URI.escape(rand_mark),
            current_user.authentication_token)
          return
        end
      end

      flash[:notice] = notice
      flash[:alert] = alert
      flash[:bookmark_notice] = added_notice

      pp flash
      
      params = {:controller => "events", :range => :next}.merge(added_params)

      redirect_to params
    else
      
    end

        
  end

end
