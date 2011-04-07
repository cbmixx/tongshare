module GroupsHelper
  def add_group(name, creator_id = current_user_id, privacy = Group::PRIVACY_PRIVATE, extra_info = nil)
    group = Group.new(:creator_id => creator_id, :name => name, :privacy => privacy, :extra_info => extra_info)
    group.save
  end

  def query_group_via_name_and_creator_id(name, creator_id)
    Group.where(:name => name, :creator_id => creator_id).first
  end

  def query_or_create_group_via_name_and_creator_id(name, creator_id)
    g = Group.where(:name => name, :creator_id => creator_id).first
    if g.nil?
      add_group(name, creator_id)
      g = Group.where(:name => name, :creator_id => creator_id).first
    end
    return g
  end

end