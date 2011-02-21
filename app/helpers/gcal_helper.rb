module GcalHelper
  def create_calendar(name = 'TongShare', token = current_user.google.client)
    service = GCal4Ruby::Service.new({:GData4RubyService => :OAuthService})
    service.authenticate(:access_token => token)
    cal = GCal4Ruby::Calendar.find(service, {:title => name})
    if cal == nil
      cal = GCal4Ruby::Calendar.new(service, 
        {:title => name,
         :timezone => 'Asia/Shanghai',
         :summary => ''
        })
      cal.save
      puts "Calendar #{name} created."
    else
      puts "Calendar #{name} exists."
    end
    return cal
  end
  def create_event(event, token = current_user.google.client)
    
  end 
end
