module SiteConnectHelper
  def parse_renren_url(str)
    return nil if str.blank?
    if str.match(/\A[0-9]+\Z/) != nil #id
      #return str
      return nil
    elsif str.match(/\/|\.|\?|\=/) == nil #domain
      #return nil if ["home", "profile"].include?(str.downcase)
      #return "domain:" + str
      return nil
    else #may be uri
      uri = URI.parse(str)
      if !uri.host.blank?
        if uri.host.match(/renren\.com/) != nil #sth. like http://xxx.renren.com/xxx
          if(uri.query.blank?)  #domain
            domain = uri.path
            domain = domain[1..-1] if domain.start_with?("/")
            return nil if domain.empty?
            return nil if ["home", "profile"].include?(domain.downcase)
            return "domain:" + domain
            #return parse_renren_url(domain)
          else  #id
            queries = CGI.parse(uri.query)
            if queries["id"].nil? || queries["id"].count != 1
              return nil
            else
              return "id:" + queries["id"][0]
            end
          end
        else
          return nil
        end
      else
        if uri.path.match(/renren\.com\//) != nil  #sth. like www.renren.com/xxx
          return parse_renren_url("http://" + str)
        else
          return nil
        end
      end
    end
  end

  def generate_renren_url(str, mobile = false)
    return nil if str.blank?
    if str.start_with?("domain:")
      return "http://www.renren.com/" + str[7..-1]  #7 = "domain:".count  #TODO: how to support custom domain for 3g.renren.com?
    elsif str.start_with?("id:")
      prefix = mobile ? "3g" : "www"
      return "http://#{prefix}.renren.com/profile.do?id=#{str[3..-1]}"
    end
  end

end
