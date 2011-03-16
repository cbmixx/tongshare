class Feedback < ActiveRecord::Base
  WARNING = "warning"
  SCORE = "score"
  DISABLE_WARNING = "disable warning"
  CHECK_IN = "check_in"
  CHECK_OUT = "check_out"

  SCORE_REGEX = /score.(\d)/

  attr_accessible :user_id, :instance_id, :value

  belongs_to :user
  belongs_to :instance
end
