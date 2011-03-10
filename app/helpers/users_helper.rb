module UsersHelper
  #currently just a constant.
  #future: get company_domain according to user if it is no nil. Or get company_domain from environment, such as host name or IP
  def company_domain(user = nil)
    "tsinghua.edu.cn"
  end

  def without_company_domain(str, user = nil)
    com = company_domain(user)
    str[(com.length+1)..-1]
  end
end
