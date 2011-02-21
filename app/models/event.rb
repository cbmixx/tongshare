require 'gcal4ruby'

class Event < ActiveRecord::Base

  MAX_INSTANCE_COUNT = 64
  # In order to make Event.new(:creator_id => creator_id) work, attr_accessible :creator_id
  # seems to be necessary!
  attr_accessible :name, :begin, :end, :location, :extra_info, :rrule, :creator_id
  attr_accessible :rrule_interval, :rrule_frequency, :rrule_days, :rrule_count

  belongs_to :creator, :class_name => "User"
  has_many :acceptances, :foreign_key => "event_id", :dependent => :destroy
  has_many :sharings, :foreign_key => "event_id", :dependent => :destroy
  has_many :reminders, :foreign_key => "event_id", :dependent => :destroy
  has_many :instances, :foreign_key => "event_id", :dependent => :destroy

  #TODO validates
  validates :name, :begin, :creator_id, :presence => true
  validates_numericality_of :rrule_count, :allow_nil => true, :only_integer => true, :greater_than_or_equal_to => 1, :less_than_or_equal_to => MAX_INSTANCE_COUNT
  validates_inclusion_of :rrule_frequency, :in => GCal4Ruby::Recurrence::DUMMY_FREQS
  #
  #

  def save
    #generate rrule
    logger.debug self.recurrence.to_yaml

    #check rrule_days
    if self.rrule_frequency == GCal4Ruby::Recurrence::WEEKLY_FREQUENCE
      if self.rrule_days.empty?
        self.rrule_days = [Date.today.wday]
      end
    else
      self.rrule_days = []
    end

    self.rrule = self.recurrence.rrule
    logger.debug self.rrule.to_yaml

    return false if !valid?
    drop_instance
    ret = generate_instance
    if !ret
      #TODO repeat_until
      return false
    end
    #seems no improving...
    #Instance.transaction do
      ret = super
    #end
    logger.debug errors.to_yaml
    return false if !ret
    #TODO edit each for better performance?
    #TODO: LC: you should return true/false. Once fail to generate, you need to rollback the newly created event.
    return true
  end

#  def update_attributes(vars = {})
#    #"super" will call "save", so no more for rrule
#
#    ret = super
#    return false if !ret
#    #TODO edit each for better performance?
#    #drop_instance
#    #generate_instance
#    #modified by Wander: do not do these two operations because update_attributes calls "save"
#  end

  #TODO untested
  #TODO group?
  def add_sharing(current_user_id, extra_info, user_ids, user_priority = UserSharing::PRIORITY_INVITE)
    # I think this won't work since sharing has no attr_accessor!
    s = self.sharings.new(:shared_from => current_user_id, :extra_info => extra_info)
    #ids = user_ids.split(%r{[,;]\s*}
    uids = User.where(:id => user_ids)
    uids.each do |id|
      s.add_user_sharing(id.id, user_priority)
    end
    ret = s.save
    # if !ret
    #   return s.errors
    # end
    # ret
  end

  def query_instance(time_begin, time_end)
    self.instances.where("begin >= ? AND end <= ?", time_begin, time_end).order("begin")
  end

  def decide_by_user(user_id, decision = Acceptance::DECISION_ACCEPTED)
    accs = self.acceptances.where("user_id = ?", user_id)
    if accs.exists?
      acc = accs.first
      acc.decision = decision
    else
      acc = self.acceptances.build(:user_id => user_id, :decision => decision)
    end
    acc.save
  end

  #TODO group
  def open_to_user?(user_id)
       self.creator_id == user_id \
    || Acceptance.where(:event_id => self.id, :user_id => user_id, :decision => Acceptance::DECISION_ACCEPTED).exists? \
    || UserSharing.joins(:sharing).where(:user_id => user_id, 'sharings.event_id' => self.id).exists?
  end

  #virtual fields for recurrence logic
  #these fields will simplify and unify new/edit in controllers
  #TODO: validates
  def recurrence
    if !defined? @recurrence
      @recurrence = GCal4Ruby::Recurrence.new
      @recurrence.from_rrule(self.rrule) unless self.rrule.blank?
    end

    @recurrence
  end

  def rrule_frequency
    ret = self.recurrence.frequency
    ret ||= GCal4Ruby::Recurrence::NONE_FREQUENCY
    ret
  end

  def rrule_frequency=(f)
    # will be checked in GCal4Ruby::Recurrence::frequency=
    self.recurrence.frequency = f
  end

  def rrule_interval
    self.recurrence.interval || 1
  end

  def rrule_interval=(i)
    self.recurrence.interval = i.to_i
  end

  def rrule_days
    ret = self.recurrence.get_days
    ret = [Date.today.wday] if ret.empty?
    ret
  end

  def rrule_days=(days)
    ret = []
    days.each do |d|
      ret << d.to_i unless d.blank?
    end
    self.recurrence.set_days(ret)
  end

  def rrule_count
    self.recurrence.count || 1
  end

  def rrule_count=(count)
    self.recurrence.count = count.to_i
  end

  def recurring?
    !self.rrule.blank?
  end

  protected
 
  def drop_instance
    if self.instances
      self.instances.each do |i|
        i.destroy
      end
    end
  end
  
  def generate_instance
    if self.rrule_frequency == GCal4Ruby::Recurrence::NONE_FREQUENCY
      i = self.instances.build(
        :override => nil,
        :name => self.name,
        :location => self.location,
        :extra_info => self.extra_info,
        :begin => self.begin,
        :end => self.end,
        :creator_id => self.creator_id
        )
      #i.save
    else
      #rec = GCal4Ruby::Recurrence.new
      #rec.from_rrule(self.rrule) # rec.load('RRULE:' + self.rrule) will encounter bug since self.rrule may begin with 'RRULE:'
      
      #modified by Wander
      rec = self.recurrence
      interval = self.rrule_interval
      if rec.frequency == 'DAILY'
        return false if rec.count > MAX_INSTANCE_COUNT
        for j in 0..(rec.count - 1)
            self.instances.build(
              :name => self.name,
              :location => self.location,
              :extra_info => self.extra_info,
              :begin => self.begin + (j * interval).day,
              :end => self.end + (j * interval).day,
              :override => false,
              :index => j,
              :creator_id => self.creator_id
            )          
        end
      elsif rec.frequency == 'WEEKLY'
        now = self.begin
        count = 0
        interval = 0
        interval = rec.interval - 1 if rec.interval > 1
        while 1
          if rec.day[now.wday]
            #
            self.instances.build(
              :name => self.name, 
              :location => self.location, 
              :extra_info => self.extra_info,
              :begin => now,
              :end => self.end + (now - self.begin),
              :override => false,
              :index => count,
              :creator_id => self.creator_id
            )
            #i.save
            count += 1
          end
          now += 3600 * 24 # now += 1.day seems to be too slow in 1.8.7
          if now.wday == 0 # now.sunday? is too new for ruby1.8.7
            now += (interval * 7).day
          end

          if count >= MAX_INSTANCE_COUNT
            return false
          end

          if rec.count and count >= rec.count.to_i
            break
          end
          
          if rec.repeat_until and now >= rec.repeat_until
            break
          end
        end
        logger.debug 'instance generated:' + self.instances.size.to_s
      elsif rec.frequency == 'MONTHLY'
        #TODO
      elsif rec.frequency == 'YEARLY'
        #TODO
      else
        logger.debug "#{__method__}:unknown frequency: #{rec.frequency}"
      end
    end
    true
  end
  
end
