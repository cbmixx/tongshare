module SharingsHelper
  #parse the raw string the user has input
  #return an array containing a hash {:type => xxx, :login_value => xxx}
  def parse_sharings_raw(str)
    result = []

    #TODO: copied from user_identifier. Consider a better code style, like putting them in configurations.
    employee_no_pattern = /^[0-9]{10}$/  #TODO: should get patterns for different schools
    mobile_pattern = /^1[0-9]{10}$/
    email_pattern = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/

    elements = str.split(/\s|,|;|\n/)
    for elem in elements
      next if elem.empty?
      if elem.match(employee_no_pattern) != nil
        type = UserIdentifier::TYPE_EMPLOYEE_NO
      elsif elem.match(email_pattern) != nil
        type = UserIdentifier::TYPE_EMAIL
      elsif elem.match(mobile_pattern) != nil
        type = UserIdentifier::TYPE_MOBILE
      else
        type = nil
      end
      result << {:type => type, :login_value => elem}
    end

    result
  end

  
end
