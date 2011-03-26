class Instance < ActiveRecord::Base
  include EventsHelper

  attr_accessible :name, :begin, :end, :location, :extra_info, :event_id, :index, :override, :creator_id
  attr_accessible :event
  belongs_to :event
  has_many :reminder_queues, :dependent => :destroy
  has_many :feedback, :dependent => :destroy

  #validates :event_id, :creator_id, :presence => true

  def warninged?(user_id)
    (Feedback.where("user_id=? AND instance_id=? AND value=?",
        user_id, self.id, Feedback::WARNING).count > 0)
  end

  def warning_count
    Feedback.where("instance_id=? AND value=?",
        self.id, Feedback::WARNING).count
  end

  def average_score_with_reliability
    feedbacks = Feedback.where("instance_id=? AND value like ?",
      self.id, Feedback::SCORE+".%").to_a
    cnt = 0
    sum = 0
    for feedback in feedbacks
      m = feedback.value.match Feedback::SCORE_REGEX
      if (m)
        sum += m[1].to_i
        cnt += 1
      end
    end
    reliability = cnt.to_f / get_attendee_count(self.event)
    return [sum.to_f / [cnt, 1].max, reliability]
  end

  def user_checked_in?(user_id)
    return checked_in?(user_id, self.id)
  end
end
