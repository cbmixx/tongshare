require 'htmlentities'

class PublicController < ApplicationController
  # JSON has some problem with UTF8 Chinese character...
  # Use XML (it's verified to work well with UTF8 Chinese character if you encounter that problem
  # Sample 1(initial request in json): http://localhost:3000/public/get_diff.json?id=tsinghua.edu.cn.9999100100
  # Sample response 1: {"events":[{"event":{"name":"\u6d4b\u8bd5\u6d3b\u52a8","begin":"2011-02-27T17:44:00+08:00","location":"\u516d\u6559;6C300","created_at":"2011-02-27T17:44:18+08:00","updated_at":"2011-02-27T18:37:34+08:00","rrule":"","id":1,"end":"2011-02-27T18:14:00+08:00","creator_id":8,"extra_info":"\u5730\u70b9\u7528\u5206\u53f7';'\u5206\u9694\u5927\u5730\u70b9\u548c\u5c0f\u5730\u70b9"}}],"time_now":"2011-02-27T18:37:40+08:00"}
  # Sample 2(initial request in xml): http://localhost:3000/public/get_diff.xml?id=tsinghua.edu.cn.9999100100
  # Sample response 2:
  #<?xml version="1.0" encoding="UTF-8"?>
  #<hash>
  #  <time-now type="datetime">2011-02-27T18:38:50+08:00</time-now>
  #  <events type="array">
  #    <event>
  #      <begin type="datetime">2011-02-27T09:44:00Z</begin>
  #      <name>&#27979;&#35797;&#27963;&#21160;</name>
  #      <created-at type="datetime">2011-02-27T09:44:18Z</created-at>
  #      <location>&#20845;&#25945;;6C300</location>
  #      <rrule></rrule>
  #      <updated-at type="datetime">2011-02-27T10:37:34Z</updated-at>
  #      <creator-id type="integer">8</creator-id>
  #      <end type="datetime">2011-02-27T10:14:00Z</end>
  #      <id type="integer">1</id>
  #      <extra-info>&#22320;&#28857;&#29992;&#20998;&#21495;';'&#20998;&#38548;&#22823;&#22320;&#28857;&#21644;&#23567;&#22320;&#28857;</extra-info>
  #    </event>
  #  </events>
  #</hash>
  # Sample 3(diff request in json): http://localhost:3000/public/get_diff.json?id=tsinghua.edu.cn.9999100100&last_update=2011/3/1
  # Sample response 3: {"events":[],"time_now":"2011-02-27T18:01:50+08:00"}
  #
  def get_diff
    id_value = params[:id]
    ui = UserIdentifier.find_by_login_value(id_value)
    if ui.nil?
      respond_to do |format|
        format.html { render :text => "user not existed" }
        format.xml { render :text => "user not existed" }
        format.json { render :text => "user not existed" }
      end
      return
    end
    
    user = ui.user
    if user.user_extra.nil? || !user.user_extra.public
      respond_to do |format|
        format.html { render :text => "user not public" }
        format.xml { render :text => "user not public" }
        format.json { render :text => "user not public" }
      end
      return
    end

    if (params[:last_update])
      last_update = Time.parse(params[:last_update]).utc
    else
      last_update = 0
    end

    events = Event.where("creator_id=? AND updated_at>?", user.id, last_update).to_a
    result = {:time_now => Time.now.localtime, :events => events}
    respond_to do |format|
      format.html { render :text => result.to_json }
      format.json { render :json => result }
      if (params[:disable_escape] && params[:disable_escape] == 'true')
        format.xml do
          coder = coder = HTMLEntities.new
          xml_result = result.to_xml
          xml_result.gsub!(/&#\d+;/) { |m| coder.decode(m)}
          render :text => xml_result
        end
      else
        format.xml { render :xml => result }
      end
    end
  end

end
