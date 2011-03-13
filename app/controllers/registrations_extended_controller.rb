class RegistrationsExtendedController < Devise::RegistrationsController
include RegistrationsExtendedHelper
include UsersHelper
include AuthHelper

  def new
    super
    authorize! :create, resource
  end

  def create
    
    #if a user has already registered the employee_id but not confirmed, we will destroy the old one
    oldone = UserIdentifier.find_by(UserIdentifier::TYPE_EMPLOYEE_NO, params[:employee_no])
    oldone.user.destroy unless oldone.nil? || oldone.confirmed


    build_resource

    #add user identifiers
    resource.user_identifier.build \
      :login_type => UserIdentifier::TYPE_EMPLOYEE_NO,
      :login_value => company_domain + "." + params[:employee_no]

    if !params[:user][:email].nil? && !params[:user][:email].empty?
      resource.user_identifier.build \
        :login_type => UserIdentifier::TYPE_EMAIL,
        :login_value => params[:user][:email]
    end

    if !params[:mobile].nil? && !params[:mobile].empty?
      resource.user_identifier.build \
        :login_type => UserIdentifier::TYPE_MOBILE,
        :login_value => params[:mobile]
    end

    #go around for email validation:
    #devise will validate email's presence and uniqueness, however we allow users register with empty email
    #to pass the validation of devise, we create a random email with pattern sth@null.tongshare.com to represent empty email
    #duplicate: theoretically it is almost impossible.
    if params[:user][:email].nil? || params[:user][:email].empty?
      username = UUIDTools::UUID.random_create
      params[:user][:email] = "#{username}@null.#{company_domain(resource)}"
      resource.email = params[:user][:email]
    end

    authorize! :create, resource

    #skip email verify always
    resource.skip_confirmation!
    
    #do what devise does
    if resource.save
      set_flash_message :notice, :signed_up

      transfer_dummy_user(params[:employee_no], company_domain, resource.id)

      #backup the current redirect_to (according to stored_location_for)
      #original_redirect = session[:user_return_to] || root_url
      original_redirect = root_url

      #devise will do the redirect to session[:user_return_to]
      if !params[:infopass].blank?
        if (params[:infopass] == THU_SPECIAL_SECRET && params[:employee_no].start_with?('9999'))
          session[:user_return_to] = original_redirect
          ui = UserIdentifier.find_by UserIdentifier::TYPE_EMPLOYEE_NO, params[:employee_no]
          ui.confirmed = true
          user = ui.user
          user.build_user_extra if user.user_extra.nil?
          user.user_extra.public = true
          user.save!
          ui.save!
        else
          session[:user_return_to] = auth_path_with_password(params[:employee_no],
            params[:infopass], original_redirect)
        end
      else
        session[:user_return_to] = auth_path(params[:employee_no], original_redirect)
      end

      sign_in_and_redirect(resource_name, resource)
      #redirect_to auth_path_with_password(params[:employee_no], params[:infopass], original_redirect)
    else
      clean_up_passwords(resource)
      render_with_scope :new
    end

  end

  def edit
    resource.build_user_extra if current_user.user_extra.nil?
    authorize! :edit, resource

    super
  end

  def update
    authorize! :update, current_user

    if (params[:user][:email].nil? || params[:user][:email].empty?)
      username = UUIDTools::UUID.random_create
      params[:user][:email] = "#{username}@null.#{company_domain(resource)}"
    end

    super
    
    email = resource.email
    email_id = UserIdentifier.find_by(UserIdentifier::TYPE_EMAIL, email)
    if (!nil_email_alias?(email) && (!resource.confirmed? || email_id.nil? || email_id.login_value != email))
      resource.send_confirmation_instructions
      flash[:notice] = I18n.t 'devise.confirmations_extended.send_instructions'
    end
  end

  def destroy
    authorize! :destroy, current_user
    super
  end
end
