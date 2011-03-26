class ApplicationController < ActionController::Base
  # mobile helper
  has_mobile_fu
  
  protect_from_forgery

  before_filter :export_i18n_messages
  before_filter :manual_notice

  private
  def export_i18n_messages
    SimplesIdeias::I18n.export! if Rails.env.development?
    #export i18n for js
  end

  def manual_notice
    if (params[:notice])
      flash[:notice] = params[:notice]
      # Anything after notice parameter is skipped!
      # So be bareful that no important parameter should ever be after notice
      redirect_to request.request_uri.sub(/[\?&]?notice=.*/, '')
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end
end

