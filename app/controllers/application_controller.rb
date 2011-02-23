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

end

