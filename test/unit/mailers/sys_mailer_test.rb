require 'test_helper'

class SysMailerTest < ActiveSupport::TestCase
  setup do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.deliveries = []
    @deliveries = ActionMailer::Base.deliveries
  end
  test "simple test for mailer" do
    size = @deliveries.size
    mail = SysMailer.test_email("foo@bar.com")
    mail.deliver
    assert @deliveries.size == size + 1
    assert @deliveries[size].to.include? "foo@bar.com"
    size += 1
  end
end
