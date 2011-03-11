require 'pp'

module ApplicationHelper
  include AuthHelper
  include CurriculumHelper

  def devise_error_messages_translated!
    return "" if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = I18n.t "activerecord.errors.template.header", :count => resource.errors.count
    html = <<-HTML
    <div id="error_explanation">
      <h2>#{sentence}</h2>
      <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end

  def content_box(title_strong = nil, title = nil, border = false, &block)
    title_str = ""
    title_str += "<span>#{title_strong}</span>" unless title_strong.blank?
    title_str += "<span>#{title}</span>" unless title.blank?
    title_str = "<h2>#{title_str}</h2>" unless title_str.blank?
    if border
      content = <<HTML
    		<div class="box">
					<div class="border-right">
						<div class="border-bot">
							<div class="border-left">
								<div class="left-top-corner">
									<div class="right-top-corner">
										<div class="inner">
											#{title_str}
											#{capture(&block)}
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
HTML
    else
      content = <<HTML
        <div class="inside">
					#{title_str}
					#{capture(&block)}
				</div>
HTML
    end
    content.html_safe
  end

  #(name, {options of url_for}
  #modified from link_to
  def styled_button(*args)
    name = args[0]
    args.delete_at(0)
    if args.last.is_a?(Hash) && (args.length > 1)
      args.last[:class] = 'link1'
    else
      args << {:class => 'link1'}
    end
    pp args

    content = '<div class="wrapper">'
    content += link_to(*args) do
      safe_concat <<HTML
        <span><span>#{name}</span></span>
HTML
    end
    content += '</div>'

    content.html_safe
  end

  def submit_button(form, id, text)
    content = <<HTML
    <div class="wrapper"><a href="#" class="link1" onclick="if($('#{id}').onsubmit==null||$('#{id}').onsubmit()){$('#{id}').submit();}"><span><span>#{text}</span></span></a></div>
HTML

    if form.nil?
      content += submit_tag(text, :style => "width:0px; height:0px; border:0px;")
    else
      content += form.submit(text, :style => "width:0px; height:0px; border:0px;")
    end
    
    content.html_safe
  end

  def header_announcement
    #check confirmation for employee_no
    user_id_rec = current_user.user_identifier.find(:first,
      :conditions => ["login_type = ?", UserIdentifier::TYPE_EMPLOYEE_NO])

    if !user_id_rec.nil?
      @not_confirmed = !user_id_rec.confirmed
      username = user_id_rec.login_value
      username = username.delete(company_domain(current_user) + ".")
      @auth_path = auth_path(username, root_url)
    end

    @curriculum_empty = curriculum_empty?(current_user)
    @renren_url_empty = (current_user.user_extra.nil? || current_user.user_extra.renren_id.blank?)

    render :partial=>"shared/header_announcement"
  end

  def sidebar_announcement
    render :partial=>"shared/sidebar_announcement"
  end

end
