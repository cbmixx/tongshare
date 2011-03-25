class ConfirmationsExtendedController < Devise::ConfirmationsController
  include RegistrationsExtendedHelper
  
  def show
    super

    if (current_user && current_user.confirmed?)
      try_set_email(current_user.email)
    end
  end
end

