require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = {
      'username' => 'atestname',
      'password' => '000000a',
      'email' => 'aisensiy@gmail.com'
    }
  end
  test "should create a new user" do
    resp = User.signup(@user)

    assert_equal 201, resp.code
    assert resp.body['objectId']
  end

  teardown do

  end
end
