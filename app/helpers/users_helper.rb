module UsersHelper
  #currently just a constant.
  #future: get company_domain according to user if it is no nil. Or get company_domain from environment, such as host name or IP
  def company_domain(user = nil)
    "tsinghua.edu.cn"
  end
end
