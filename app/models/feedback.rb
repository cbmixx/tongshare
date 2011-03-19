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

  validate :value_validate

  def value_validate
    if (m = value.match(SCORE_REGEX))
      score = m[1].to_i
      result = (score >=1 && score <= 5)
    else
      result = (value == WARNING || value == CHECK_IN)
    end
    errors.add(:value, :invalid) unless result
  end
end
