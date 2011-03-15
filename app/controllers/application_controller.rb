class ApplicationController < ActionController::Base
  # mobile helper
  has_mobile_fu
  
  protect_from_forgery

  before_filter :export_i18n_messages

  private
  def export_i18n_messages
    SimplesIdeias::I18n.export! if Rails.env.development?
    #export i18n for js
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end
end

