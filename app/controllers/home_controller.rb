#by Wander
#home for the whole site. Currently it is used for testing

class HomeController < ApplicationController
  def index

    logger.debug "UserAgent: " + request.env["HTTP_USER_AGENT"]

    if user_signed_in?
      flash[:notice] = notice
      flash[:alert] = alert
      redirect_to :controller => "events", :range => :next
    else
      
    end

        
  end

end
