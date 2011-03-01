module SharingsHelper
  def find_duplicated_sharing(current_user_id, event_id, user_ids)
    query = UserSharing.joins(:sharing).where('sharings.shared_from' => current_user_id, 'sharings.event_id' => event_id, :user_id => user_ids).to_a
    query.map! {|q| q.user_id}
    query << current_user_id if (!query.include?(current_user_id) && user_ids.include?(current_user_id))
    query
  end
  
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
