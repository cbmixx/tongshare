require 'test_helper'

class TempTest < ActiveSupport::TestCase
  test "Time" do
    t = Time.now
    assert t + 1.day == t + 3600 * 24
  end
end
