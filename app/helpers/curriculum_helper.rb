module CurriculumHelper
  #check whether the user has imported a curriculum
  def curriculum_empty?(user)
    ret = user.acceptance.find(:first,
      :joins => [:event],
      :conditions => ['events.creator_id = 1'])
    return ret.nil?
  end
end
