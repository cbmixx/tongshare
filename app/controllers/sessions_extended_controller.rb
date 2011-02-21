class SessionsExtendedController < Devise::SessionsController
  include UsersHelper
  def new
    super
  end

  def create
    #find user_id for devise
    user_id_rec = UserIdentifier.find \
      :first,
      :conditions => ["login_type = ? AND login_value = ?",
                      params[:login_type],
                      company_domain + "." + params[:login_value]
      ] #TODO: for other types, no company_domain!!

    #logger.debug "Result: #{user_id_rec.to_yaml}"

    if user_id_rec.nil?
      params[:user][:id] = -1
    else
      params[:user][:id] = user_id_rec.user_id
    end

    #logger.debug params.to_yaml

    if !user_id_rec.nil? && !user_id_rec.confirmed
      flash[:notice] = "您的帐号未能通过验证，请尝试重新注册。"
      redirect_to new_user_registration_path(:employee_no => params[:login_value])
      return
    end

    super
  end

end
