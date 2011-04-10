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
      original_redirect = session[:user_return_to] || root_url
      puts "TEST REDIRECT: " + original_redirect
      unless (original_redirect.start_with?('/') || original_redirect.start_with?('http'))
        original_redirect = '/'+original_redirect
      end
      original_redirect = "http://" + SITE + original_redirect unless (original_redirect.include? SITE)
      #original_redirect = root_url

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

    if current_user
      if current_user.user_extra
        @photo_url = current_user.user_extra.photo_url
      end
    end
    super
  end

  def update
    authorize! :update, current_user

    if (params[:user][:email].nil? || params[:user][:email].empty?)
      username = UUIDTools::UUID.random_create
      params[:user][:email] = "#{username}@null.#{company_domain(resource)}"
      email_id = UserIdentifier.find_by_user_id_and_login_type(current_user.id, UserIdentifier::TYPE_EMAIL)
      email_id.destroy unless email_id.nil?
    end

    # TODO HACK THIS EMAIL FOR EXISTED DUMMY
    email = params[:user][:email]
    email_id = UserIdentifier.find_by(UserIdentifier::TYPE_EMAIL, email)
    if (email && !nil_email_alias?(email) && (!resource.confirmed? || email_id.nil? || email_id.login_value != email))
      params[:user][:email] = encode_email(email)
    end

    s = super
    return s if (s.class != String) # Something is wrong, so we returned.
    
    email = decode_email(resource.email)
    email_id = UserIdentifier.find_by(UserIdentifier::TYPE_EMAIL, email)
    if (!nil_email_alias?(email) && (!resource.confirmed? || email_id.nil? || email_id.login_value != email))
      # A very long hack to avoid email conflict with dummy
      dummy = check_or_create_general_dummy_user(UserIdentifier::TYPE_EMAIL, UserIdentifier::TYPE_EMAIL_DUMMY, email)
      dummy.email = "#{UUIDTools::UUID.random_create}@dummy.com"
      dummy.save!
      resource.email = email
      resource.send_confirmation_instructions
      resource.email = encode_email(email)
      resource.save!
      dummy.email = email
      dummy.save!
      flash[:notice] = I18n.t 'devise.confirmations_extended.send_instructions'
    end

    if (resource.user_extra.renren_url)
      resource.user_extra.profile_status = User::PROFILE_CONFIRMED
      resource.user_extra.save!
    end

    if (params[:user][:user_extra_attributes][:avatar])
      resource.user_extra.photo_url = resource.user_extra.avatar.url(:thumb)
      resource.user_extra.save!
    end
  end

  def destroy
    authorize! :destroy, current_user
    super
  end
end
