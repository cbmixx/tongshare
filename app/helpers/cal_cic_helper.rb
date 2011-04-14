module CalCicHelper
  XML_PATH = "http://cal.cic.tsinghua.edu.cn:80/cal_pub/cal_pub/calendarXml.action"
  require 'net/http'
  require 'rexml/document'
  def import_all(user_id)
    url = URI.parse(XML_PATH)
    post_args = {'calendar.startDate' => '20101230T053000Z', 'calendar.endDate' => '20111230T053000Z'}
    resp, data = Net::HTTP.post_form(url, post_args)

    doc = REXML::Document.new(data)
    doc.elements.each('calendar/event') do |e|
      name = e.get_elements('summary').first.text
      start_time = Time.parse(e.get_elements('startTime').first.text).getlocal
      end_time = Time.parse(e.get_elements('endTime').first.text).getlocal
      if end_time - start_time == 24 * 60 * 60 && end_time.hour == 0 && end_time.min == 0 && end_time.sec == 0
        end_time -= 1
      end
      location = e.get_elements('location').first.text
      location = '' if location.nil?
      extra_info = e.get_elements('description').first.text
      v = Event.new(
        :creator_id => user_id,
        :begin => start_time,
        :end => end_time,
        :name => name,
        :location => location,
        :extra_info => extra_info,
        :rrule_frequency => GCal4Ruby::Recurrence::NONE_FREQUENCY)
      v.save
    end
  end

  def destroy_all_events_of_user(user_id)
    a = Event.find_all_by_creator_id user_id
    a.each do |e|
      e.destroy
    end
  end
  
end