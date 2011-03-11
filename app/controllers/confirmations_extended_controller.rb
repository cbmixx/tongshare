class ConfirmationsExtendedController < Devise::ConfirmationsController
  def show
    puts "TEST A"

    super

    puts "TEST B"
    if (current_user.confirmed?)
      email_id = UserIdentifier.find_by_user_id_and_login_type(current_user.id, UserIdentifier::TYPE_EMAIL)
      email_id.destroy unless email_id.nil?
      UserIdentifier.create!(:user_id => current_user.id,
        :login_type => UserIdentifier::TYPE_EMAIL,
        :login_value => current_user.email,
        :confirmed => true)
    end
  end
end

