class CurriculumController < ApplicationController
  include EventsHelper

  before_filter :authenticate_user!

  def upload
    respond_to do |format|
      format.html
    end
  end

  def save
    #logger.debug params[:xls_file].to_yaml
    begin
      ret = xls2events params[:xls_file].read, current_user.id
    rescue Exception => e
      logger.error e.to_yaml
      ret = false
    end

    respond_to do |format|
      if ret
        format.html {redirect_to :root, :notice => I18n.t('tongshare.curriculum.import_finish')}
      else
        format.html {redirect_to({:action => "upload"}, :alert => I18n.t('tongshare.curriculum.import_failed'))}
      end
    end

  end

end
