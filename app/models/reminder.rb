class Reminder < ActiveRecord::Base
  METHOD_EMAIL = 0
  METHOD_MOBILE = 1
  METHODS = [METHOD_EMAIL, METHOD_MOBILE]

  TIME_DAY = 0
  TIME_HOUR = 1
  TIME_MINUTE = 2
  TIME_SECOND = 3
  TIMES = [TIME_DAY, TIME_HOUR, TIME_MINUTE, TIME_SECOND]

  attr_accessible :method_type, :value, :time_type
  belongs_to :event
  has_many :reminder_queues, :dependent => :destroy
  
  validates_inclusion_of :method_type, :in => METHODS
  validates_inclusion_of :time_type, :in => TIMES
  validates_numericality_of :value, :only_integer => true

  validate do |reminder|
    reminder.reminder_queues.each do |rq|
      next if rq.valid?
      rq.errors.each do |attr, err|
        errors.add attr, err
      end
    end
  end


  def save
    drop_reminder_queue
    generate_reminder_queue
    ret = super
    self.reminder_queues(true)
    ret
  end

  def value_in_second
    if time_type == TIME_DAY
      value * 24 * 3600
    elsif time_type == TIME_HOUR
      value * 3600
    elsif time_type == TIME_MINUTE
      value * 60
    elsif time_type == TIME_SECOND
      value 
    end
  end
  
  protected
  def generate_reminder_queue
    v = value_in_second
    self.event.instances.each do |i|
      if i.begin - v > Time.now
        self.reminder_queues.build(:method_type => method_type, :time => i.begin - v, :instance_id => i.id)
      end
    end
  end

  def drop_reminder_queue
    self.reminder_queues.each do |rq|
      rq.destroy
    end
  end
  
end
