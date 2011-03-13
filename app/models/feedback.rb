class Feedback < ActiveRecord::Base
  WARNING = "warning"
  SCORE = "score"
  DISABLE_WARNING = "disable warning"

  SCORE_REGEX = /score.(\d)/

  attr_accessible :user_id, :instance_id, :value

  belongs_to :user
  belongs_to :instance
end
