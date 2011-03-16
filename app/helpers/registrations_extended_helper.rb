module RegistrationsExtendedHelper
  
  include UsersHelper
  #check if a given email is null alias (xxx@null.yyy.zzz)
  def nil_email_alias?(email, user = nil)
    not email.match(/.+@null.#{company_domain(user)}/).nil?
  end

  def more_login_used?
    return false if params.nil?
    return true if \
      !params[:user].nil? \
        && !params[:user][:email].nil? \
        && !params[:user][:email].empty? \
        && !nil_email_alias?(params[:user][:email])
    
    return true if !params[:mobile].nil? && !params[:mobile].empty?
    return false
  end

  def login_invalid?(field)
    return false if (!defined? resource || resource.valid?)

    login_errors = resource.errors[:login_value]
    return false if login_errors.nil?

    #logger.debug login_errors[0]
    #logger.debug(I18n.t "activerecord.errors.models.user_identifier.attributes.login_value.#{field}_invalid")
    login_errors.include?(I18n.t "activerecord.errors.models.user_identifier.attributes.login_value.#{field}_invalid")
  end

  def label_for_login(field)
    div_tag = login_invalid?(field) ? "<div class=\"field_with_errors\" style=\"display:inline\">".html_safe : "<div style=\"display:inline\">"
    field_name = I18n.t "activerecord.attributes.user_identifier.#{field.to_s}"
    
    content = <<HTML
    #{div_tag}
      <label for="#{field}" class="title">#{field_name}</label>
    </div>
HTML
    content.html_safe
  end

  def text_field_for_login(field)
    div_tag = login_invalid?(field) ? "<div class=\"field_with_errors\" style=\"display:inline\">".html_safe : "<div style=\"display:inline\">"
    field_tag = text_field_tag field, params[field], :max_length => UserIdentifier::MAX_VALUE_LENGTH, :class => "textvalue"

    content = <<HTML
    #{div_tag}
      #{field_tag}
    </div>
HTML
    content.html_safe
  end

  #create a dummy user with only user_id and an employee_no in user_identifier. raise exceptions when error occurs.
  #(1) If no user exists with "employee_no", create a dummy and return the new dummy user.
  #(2) If a dummy exists with "employee_no", return the existing dummy user.
  #(3) If a real user exists with "employee_no", return the existing real user.
  def check_or_create_dummy_user(employee_no, company_domain)
    #dummy_identifier = UserIdentifier.find_by_login_type_and_login_value(UserIdentifier::TYPE_EMPLOYEE_NO_DUMMY,
    #                company_domain + "." + employee_no)
    dummy_identifier = UserIdentifier.find(:first, :conditions => [
            "(login_type = ? OR login_type = ?) AND login_value = ?",
            UserIdentifier::TYPE_EMPLOYEE_NO_DUMMY,
            UserIdentifier::TYPE_EMPLOYEE_NO,
            company_domain + "." + employee_no
        ])
    return dummy_identifier.user if !dummy_identifier.nil?

    user = User.new :email => "#{UUIDTools::UUID.random_create}@null.#{company_domain}",
                    :password => random_password
    user.user_identifier.build :login_type => UserIdentifier::TYPE_EMPLOYEE_NO_DUMMY,
                               :login_value => company_domain + "." + employee_no
    user.skip_confirmation!
    user.save!
    user
  end

  # Generate dummy user with general login type (employee_no or email or anything else)
  def check_or_create_general_dummy_user(login_type, dummy_type, login_value)
    #dummy_identifier = UserIdentifier.find_by_login_type_and_login_value(UserIdentifier::TYPE_EMPLOYEE_NO_DUMMY,
    #                company_domain + "." + employee_no)
    dummy_identifier = UserIdentifier.find(:first, :conditions => [
            "(login_type = ? OR login_type = ?) AND login_value = ?",
            login_type,
            dummy_type,
            login_value
        ])
    return dummy_identifier.user if !dummy_identifier.nil?

    if (login_type != UserIdentifier::TYPE_EMAIL)
      user = User.new :email => "#{UUIDTools::UUID.random_create}@null.#{company_domain}",
                      :password => random_password
    else
      user = User.new :email => login_value, :password => random_password
    end

    user.user_identifier.build :login_type => dummy_type, :login_value => login_value
    user.save!
    user
  end

  #Substitute the dummy user (if exist) with a real user. Transfer all data related to the dummy user to the real one, and delete the dummy
  def transfer_dummy_user(employee_no, company_domain, new_user_id)
    #try to find the dummy
    dummy_identifier = UserIdentifier.find_by_login_type_and_login_value(UserIdentifier::TYPE_EMPLOYEE_NO_DUMMY,
                        company_domain + "." + employee_no)
    return if dummy_identifier.nil?
    dummy = dummy_identifier.user
    
    UserSharing.update_all("user_id = #{new_user_id}", "user_id = #{dummy.id}")
    dummy.destroy
  end

  #Substitute the dummy user (if exist) with a real user. Transfer all data related to the dummy user to the real one, and delete the dummy
  def transfer_general_dummy_user(dummy_type, dummy_value, new_user_id)
    #try to find the dummy
    dummy_identifier = UserIdentifier.find_by_login_type_and_login_value(dummy_type,
                        dummy_value)
    return false if dummy_identifier.nil?
    dummy = dummy_identifier.user

    UserSharing.update_all("user_id = #{new_user_id}", "user_id = #{dummy.id}")
    dummy.destroy
  end

  def random_password(size = 8)
    chars = (('a'..'z').to_a + ('0'..'9').to_a) - %w(i o 0 1 l 0)
    (1..size).collect{|a| chars[rand(chars.size)] }.join
  end

  def try_set_email(email)
    email = decode_email(email)
    return false if (email.nil? || nil_email_alias?(email) || email.blank?)
    transfer_general_dummy_user(UserIdentifier::TYPE_EMAIL_DUMMY, email, current_user.id)
    current_user.email = email
    current_user.skip_confirmation!
    current_user.save!
    email_id = UserIdentifier.find_by_user_id_and_login_type(current_user.id, UserIdentifier::TYPE_EMAIL)
    email_id.destroy unless email_id.nil?
    UserIdentifier.create!(:user_id => current_user.id,
      :login_type => UserIdentifier::TYPE_EMAIL,
      :login_value => current_user.email,
      :confirmed => true)
  end

  SUPER_UNCOMMON_PREFIX = "NOBODY_SHOULD_USE_THIS_STRING_AS_EMAIL_PREFIX."

  def encode_email(email)
    if (email.start_with?(SUPER_UNCOMMON_PREFIX))
      return email
    else
      return SUPER_UNCOMMON_PREFIX + email
    end
  end

  def decode_email(email)
    if (email.start_with?(SUPER_UNCOMMON_PREFIX))
      return email[SUPER_UNCOMMON_PREFIX.length...email.length]
    else
      return email
    end
  end

end
