require 'base64'
require 'digest/sha2'

class AuthController < ApplicationController
  include EventsHelper
  include UsersHelper
  skip_before_filter :verify_authenticity_token

  def confirm
    name = params[:name]
    username = params[:username] # 学号
    hash_value = params[:hash]
    data = Base64.decode64(params[:data])
    @output = "params not valid"
    return unless name && username && hash_value && data
    my_hash = (Digest::SHA2.new << (username + name + SECRET)).to_s
    @output = "hash not valid"
    return unless my_hash == hash_value
    @output = "accepted"

#    query = UserIdentifier.where(:login_value => "tsinghua.edu.cn.#{username}")
#    if query.exists?
#      ui = query.first
#      id = ui.user_id
#
#      #add confirmation
#      ui.confirmed = true
#      ui.save!
#
#      #add name
#      ues = UserExtra.where(:user_id => id)
#      if ues.exists?
#        ue = ues.first
#      else
#        ue = UserExtra.new(:user_id => id)
#      end
#      ue.name = name
#      ue.save!
#      xls2events data, id
#    end
# strange problem. try another approach...

    ui = UserIdentifier.find_by UserIdentifier::TYPE_EMPLOYEE_NO, username
    if !ui.nil?
      #add name
      user = ui.user
      user.build_user_extra if user.user_extra.nil?
      user.user_extra.name = name
      user.save!

      xls2events data, user.id

      #add confirmation
      ui.confirmed = true
      ui.save!
    end

    respond_to do |format|
      format.html {render :text => "accepted" }
    end
  end
end
